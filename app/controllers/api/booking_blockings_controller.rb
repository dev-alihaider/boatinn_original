# frozen_string_literal: true

module Api
  # REST JSON API for blocking bookings: seller user can Create/Read/Delete
  # booking blockings.
  class BookingBlockingsController < Api::GenericController
    before_action :authenticate_user!, :authorize_user!
    before_action :define_boat_booking_blockings
    before_action :validate_optional_rental_type!, except: :destroy
    before_action :validate_dates_presence!, only: %i[create destroy_range]
    before_action :validate_dates_format!, except: :destroy

    # GET /api/boats/:boat_id/booking_blockings.json
    # Pagination for @booking_blockings/@bookings:
    #   .page(params[:page].presence || 1)
    #   .per(params[:per_page].presence || 10)
    def index
      params[:rental_type] = nil if params[:rental_type] == 'all'

      @booking_blockings = @booking_blockings
                           .within_dates(params[:date_from], params[:date_to])
                           .with_rental_type(params[:rental_type])
                           .order_by_started_at

      @bookings = @boat.bookings.opened.within_dates(params[:date_from],
                                                     params[:date_to])
                       .with_rental_type(params[:rental_type])
    end

    # POST /api/boats/:boat_id/booking_blockings.json
    # Run validations:
    #   `@booking_blockings.map(&:valid?)`
    # Raise `ActiveRecord::RecordInvalid` + validation errors messages:
    #   `@booking_blockings.map(&:save!)`
    def create
      dates_range = params[:date_from]..params[:date_to]
      rental_type = params[:rental_type] || :classic
      attributes = []

      dates_range.each do |date|
        dates = { started_at: date, finished_at: date }

        if params[:rental_type] == 'all'
          (rental_types - ['all']).each do |type|
            attributes << { rental_type: type }.merge(dates)
          end
        else
          attributes << { rental_type: rental_type }.merge(dates)
        end
      end

      @booking_blockings = @booking_blockings.new(attributes)
      @booking_blockings.map(&:valid?)

      return render_error_during_booking if @booking_blockings
                                            .select(&:during_booking?).any?

      @booking_blockings.map(&:save!)

      return if @booking_blockings.select(&:valid?).count !=
                @booking_blockings.count

      render status: :created
    end

    # DELETE /api/boats/:boat_id/booking_blockings/:id.json
    def destroy
      @booking_blockings = @booking_blockings.find(params[:id]).destroy

      head :no_content unless @booking_blockings.destroyed?
    end

    # DELETE /api/boats/:boat_id/booking_blockings.json
    def destroy_range
      dates_range = params[:date_from]..params[:date_to]

      rental_type = if params[:rental_type] == 'all'
                      params[:rental_type] = nil
                      rental_types - ['all']
                    else
                      params[:rental_type] || :classic
                    end

      bookings = @boat.bookings.opened.within_dates(params[:date_from],
                                                    params[:date_to])
                      .with_rental_type(params[:rental_type])

      return render_error_during_booking if bookings.present?

      @booking_blockings = @booking_blockings.where(started_at: dates_range,
                                                    finished_at: dates_range,
                                                    rental_type: rental_type)
                                             .destroy_all

      head :no_content if @booking_blockings.blank?
    end

    private

    def define_boat_booking_blockings
      @boat = current_user.boats.find(params[:boat_id])
      @booking_blockings = @boat.booking_blockings
    end

    def rental_types
      Travel::BookingBlocking.rental_types.keys + ['all']
    end

    def validate_optional_rental_type!
      return if params[:rental_type].blank? ||
                rental_types.include?(params[:rental_type])

      raise ArgumentError, <<~ERROR_MESSAGE.tr("\n", ' ').strip
        Invalid value for `rental_type`. Allowed values: `#{rental_types
                                                              .join('`, `')}`.
      ERROR_MESSAGE
    end

    # TODO: Add separated dates validation same as in #validate_dates_format!
    # TODO: Add validation for situation when `date_from` > `date_to`
    def validate_dates_presence!
      return if dates_present?

      raise ArgumentError,
            'Please include `date_from`, `date_to` request params.'
    end

    def validate_dates_format!
      return unless dates_present?

      errors = "#{validate_date!(:date_from)} #{validate_date!(:date_to)}".strip
      raise ArgumentError, errors if errors.present?
    end

    def dates_present?
      @dates_present ||= params[:date_from].present? &&
                         params[:date_to].present?
    end

    # Converts to Date object, modify `params` hash to use dates in model scope.
    def validate_date!(param)
      params[param] = params[param].to_date
      ''
    rescue ArgumentError
      "Invalid date format for `#{param}` request param."
    end

    def authorize_user!
      return if user_have_rights?

      json_response(
        { error: 'Forbidden',
          message: "You don't have permission to perform this action" },
        status(:forbidden)
      )
    end

    def user_have_rights?
      current_user.boats.exists?(params[:boat_id])
    end

    def render_error_during_booking
      json_response(
        { error: 'Unprocessable Entity',
          message: t('users.calendar.cannot_modify_booked_dates') },
        status(:unprocessable_entity)
      )
    end
  end
end
