# frozen_string_literal: true

module Api
  # REST JSON API for boats search.
  # NOTE: `params[:key].present?` used to avoid SQL queries with empty values.
  class BoatsController < Api::GenericController
    # GET /api/boats.json
    def index
      # @boats = Boat.finished
      #              .within_25_km(params[:lat], params[:lng])
      #              .not_blocked_dates(params[:check_in_date],
      #                                 params[:check_out_date])
      #              .can_book_now(rental_type,
      #                            params[:check_in_date],
      #                            params[:check_out_date])
      #              .passengers_count(params[:passengers_count])
      #              .captain_any(params[:with_captain])
      # boat_type_filter
      # rental_type_filter
      # experiences_filter
      # price_filter
      # order
      # paginate

      rentals = {'1' => :classic, '2' => :shared, '3' => :sleepin }
      seacher = BoatSearcher.new(rentals[params[:rental_type]] || :classic)
      @boats = seacher.where(params).paginate_and_order(params[:page], params[:per_page]).scope

      @min_price = seacher.minimum_price
      @max_price = seacher.maximum_price
    end

    # PUT/PATCH /api/boats/:id.json
    # TODO: Add authentication for UPDATE
    def update
      boat = Boat.find(params[:id])
      update_params = params_to_boolean(
        params.permit!.except(:format, :controller, :action),
        :classic, :sleepin, :shared, :instant_booking_classic
      )

      # keys = update_params.keys
      # if (keys.include?('classic') || keys.include?('sleepin') || keys.include?('shared')) && !boat.user.payoutable?
      #   json_response(
      #     { error: 'Unprocessable Entity',
      #       message: t('bookings.errors.add_payout_before') },
      #     status(:unprocessable_entity)
      #   ) and return
      # end

      previous_updated_at = boat.updated_at
      boat.update(update_params)
      head :not_modified if boat.updated_at == previous_updated_at
      ListingUpdatedJob.perform_later(boat.id)
    end

    def calculate_subtotal
      validator = TravelService::Validator.initiate_new_travel(params, User.new)
      unless validator[:success]
        render json: {error: flash[:error] = t("bookings.created_errors.#{validator[:error_code]}")} and return
      end

      @travel = validator[:data]
    end

    # GET /api/boats/:id/calculate_price.json
    # Calculate boat booking price for 1 person for [check in..check out]
    # period (in days) for half day/full day/night/week/shared/sleepin
    # according to season rates.
    # TODO: Maybe add `persons_count` or `passengers_count` param.
    def calculate_price
      boat = Boat.find(params[:id])
      unless [params[:check_in_date], params[:check_out_date],
              params[:price_for]].all?
        return raise ArgumentError, <<~ERROR_MESSAGE.tr("\n", ' ').strip
          Please include `check_in_date`, `check_out_date`, `price_for` request
          params.
        ERROR_MESSAGE
      end

      @price = 0
      # TODO: Add check for `check_in_date > current_date` to avoid bug 1970
      check_in_date  = params[:check_in_date].to_date
      check_out_date = params[:check_out_date].to_date

      if check_in_date > check_out_date
        check_in_date, check_out_date = check_out_date, check_in_date
      end

      # Calculate price by check in date if difference == 1 day.
      check_out_date = check_in_date if check_out_date - check_in_date == 1

      # To calculate only nights = intervals between days = days count - 1.
      if params[:price_for] == 'night' && check_out_date != check_in_date
        check_out_date -= 1
      end

      (check_in_date..check_out_date).each do |day|
        day_season_rate =
          boat.season_rates.where('? BETWEEN started_at AND finished_at', day)
              .first

        # TODO: Performance improvement: move this condition outside `each`.
        @price += case params[:price_for]
                  when 'half_day'
                    (day_season_rate || boat).per_half_day.to_f
                  when 'day'
                    (day_season_rate || boat).per_day.to_f
                  when 'night'
                    (day_season_rate || boat).per_night.to_f
                  when 'week'
                    (day_season_rate || boat).per_week.to_f / 7
                  when 'shared'
                    boat.shared_price.to_f
                  when 'sleepin'
                    boat.sleepin_per_night.to_f
                  else
                    raise ArgumentError, <<~ERROR_MESSAGE.tr("\n", ' ').strip
                      Unknown `price_for` value. Allowed values: `half_day`,
                      `day`, `night`, `week`, `shared`, `sleepin`.
                    ERROR_MESSAGE
                  end
      end

      days_count = (check_in_date..check_out_date).count
      weeks_count = (days_count / 7).round

      @price /= if params[:price_for] == 'week' && !weeks_count.zero?
                  weeks_count
                else
                  days_count
                end
    end

    private

    # == Filters methods ==

    # Type of boat = [1+ ids].
    def boat_type_filter
      return unless params[:boat_types].present?

      @boats = @boats.boat_type(param_to_ids_array(:boat_types))
    end

    # Type of rental = 1 (classic) | 2 (shared) | 3 (sleepin).
    def rental_type_filter
      @price_type = case params[:rental_type].to_i
                    when 1
                      @rental_type = :classic
                      @boats = @boats.classic
                      :per_half_day
                    when 2
                      @rental_type = :shared
                      @boats = @boats.shared
                      :shared_price
                    when 3
                      @rental_type = :sleepin
                      @boats = @boats.sleepin
                      :sleepin_per_night
                    else # Not set: display any enabled boat.
                      @rental_type = :classic
                      @boats = @boats.enabled
                      :per_half_day
                    end
    end

    # Experiences = [0+ ids].
    # NOTE: This also works:
    #   .where(boats_features: { feature_id: experiences_ids })
    def experiences_filter
      return unless params[:experiences].present?

      @boats = @boats.includes(:features)
                     .where(features: { id: param_to_ids_array(:experiences) })
    end

    # Min/Max prices => [min_price; max_price]
    # NOTE: params[:min_price] OR params[:max_price] OR both must be present.
    # NOTE: `max_price + 1` in `where(price_type => min_price..max_price + 1)`
    # for fix bugs with rounding currency to lower bound and some listings
    # cutted off, because they have a larger price.
    def price_filter
      @min_price = @boats.minimum(price_type)
      @max_price = @boats.maximum(price_type)

      return unless params[:min_price].present? || params[:max_price].present?

      @boats = @boats.where(price_type => min_price..max_price)
    end

    # Ordering.
    def order
      @boats = @boats.by_date_desc
    end

    # Pagination: page, per page.
    def paginate
      page = params[:page].presence || 1
      # FIXME: `out_of_range?` not working correctly.
      # page = 1 if @boats.page(page).out_of_range?
      @boats = @boats.page(page)
      @boats = @boats.per(params[:per_page]) if params[:per_page].present?
    end

    # == Utility methods ==

    # @return [Array]
    def param_to_ids_array(key)
      ids_array = params[key]
      ids_array = ids_array.split(',') if params[key].is_a?(String)
      ids_array.map(&:to_i)
    end

    # @return [Float]
    def min_price
      min = params[:min_price].presence || @min_price
      helpers.in_default_currency(min).to_f
    end

    # @return [Float]
    def max_price
      max = params[:max_price].presence || @max_price
      helpers.in_default_currency(max).to_f
    end

    # Converts any values to Boolean. Used to convert values before querying DB.
    #
    # - any value in `[false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"]`
    #   will be coerced to `false`
    # - empty strings are coerced to `nil` => `false` via `!!ActiveModel...`
    # - all other values will be coerced to `true`
    #
    # @return [Boolean]
    def boolean(value)
      !!ActiveModel::Type::Boolean.new.cast(value)
    end

    def price_type
      @price_type ||= :per_half_day
    end

    def params_to_boolean(params, *boolean_keys)
      params.each_pair do |key, value|
        params[key] = if boolean_keys.include?(key.to_sym)
                        boolean(value)
                      else
                        value
                      end
      end
    end

    def rental_type
      { '1' => :classic, '2' => :shared, '3' => :sleepin }[params[:rental_type]]
    end
  end
end
