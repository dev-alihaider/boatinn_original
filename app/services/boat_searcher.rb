class BoatSearcher
  WITHIN_DISTANCE_KM = 1000
  CHECK_IN_START_AT = Time.new(2000, 1, 1, 0, 0, 0, 0)

  attr_accessor :scope, :rental, :params, :with_distance

  def initialize(rental_type = :classic, boats_scope = nil)
    @scope = boats_scope || Boat
    @rental = rental_type.to_s.to_sym
    @params = {}
    apply_rental_type
  end

  def paginate_and_order(current_page, per_page)
    @scope = @scope.by_date_desc

    current_page = current_page.to_i
    current_page = 1 if current_page.zero?

    per_page = per_page.to_i
    per_page = 12 if per_page.zero?

    @scope = @scope.page(current_page).per(per_page)

    self
  end

  def where(filter)
    filter = permit_search_params(filter)
    @params.merge!(filter)

    apply_location(filter[:lat], filter[:lng], WITHIN_DISTANCE_KM)

    if filter[:check_in] && rental != :shared
      apply_available_period(filter[:check_in], (filter[:check_out] || filter[:check_in]))
    elsif filter[:check_in]
      apply_available_date_shared(filter[:check_in])
    end

    apply_min_passengers(filter[:min_passengers])

    if filter[:with_captain] && rental == :classic
      @scope.where!(captain: [filter[:with_captain], :with_or_without])
    end

    if filter[:experiences]
      @scope = @scope.includes(:features)
                 .where(features: { id: filter[:experiences] })
    end

    if filter[:boat_types]
      @scope.where!(boat_type: filter[:boat_types])
    end

    apply_min_and_max_prices(filter[:min_price], filter[:max_price])

    self
  end

  def minimum_price
    if rental == :classic
      half_day = @scope.minimum(:per_half_day).to_i
      return half_day.positive? ? half_day : @scope.minimum(:per_day)
    end

    @scope.minimum(price_field)
  end

  def maximum_price
    @scope.maximum(price_field)
  end

  private

  def permit_search_params(params)
    filter = {
      check_in: DateService.parse(params[:check_in_date]),
      check_out: DateService.parse(params[:check_out_date]),
      min_passengers: params[:passengers_count].to_i
    }
    location = params[:location] || { lat: params[:lat], lng: params[:lng] }
    if location[:lat] && location[:lng]
      filter.merge!({lat: location[:lat], lng: location[:lng]})
    end

    if %w[with without].include?(params[:with_captain])
      filter[:with_captain] = params[:with_captain]
    end

    if params[:experiences]
      filter[:experiences] = data_to_ids_array(params, :experiences)
    end

    if params[:boat_types]
      filter[:boat_types] = data_to_ids_array(params, :boat_types)
    end

    filter[:min_price] = params[:min_price].to_i
    filter[:max_price] = params[:max_price].to_i

    filter
  end

  def apply_rental_type
    @scope =  case rental
              when :classic then scope.where(classic: true)
              when :shared then scope.where(shared: true)
              when :sleepin then scope.where(sleepin: true)
              else raise ArgumentError, "provided invalid rental type - `#{rental}`"
              end
  end

  def apply_location(lat, lng, radius_km)
    return unless lat && lng
    @scope = @scope.joins(:location).within(radius_km, origin: [lat, lng])
    @scope = @scope.by_distance(origin: [lat, lng])
  end

  def apply_available_period(from, to)
    available_from = Time.zone.now + TravelService::Preference::PRE_BOOKING_MIN_TIME

    from = available_from if from < available_from
    to = available_from if to < available_from

    if from.to_date == available_from.to_date
      now = Time.zone.now
      h, m, s = now.hour, now.min, now.sec
    else
      h, m, s = '00', '00', '00'
    end

    period = "BETWEEN '#{from.strftime("%Y-%m-%d #{h}:#{m}:#{s}")}' AND '#{to.strftime("%Y-%m-%d 23:59:59")}'"

    trip_id_sql = "
      SELECT travel_trips.id FROM travel_trips where travel_trips.boat_id = boats.id
        AND (travel_trips.check_in #{period} OR travel_trips.check_out #{period})
        AND travel_trips.status IN(0, 3) LIMIT 1
    "

    @scope = scope.joins("LEFT JOIN travel_trips ON travel_trips.id = (#{trip_id_sql})")
    @scope = scope.where("travel_trips.id IS NULL")

    if rental == :sleepin
      @scope.where!("boats.sleepin_check_in_time > #{date_time_db(available_check_in(from))}")
    else
      @scope.where!("boats.check_in_time > #{date_time_db(available_check_in(from))}")
    end

    apply_blocked_period(from, to)
  end

  def apply_available_date_shared(check_in)

    available_from = Time.zone.now + TravelService::Preference::PRE_BOOKING_MIN_TIME
    date = check_in > available_from ? check_in : available_from

    if date.to_date == available_from.to_date
      now = Time.zone.now
      h, m, s = now.hour, now.min, now.sec
    else
      h, m, s = '00', '00', '00'
    end

    period = "BETWEEN '#{date.strftime("%Y-%m-%d #{h}:#{m}:#{s}")}' AND '#{date.strftime("%Y-%m-%d 23:59:59")}'"

    trip_id_sql = "
      SELECT travel_trips.id FROM travel_trips where travel_trips.boat_id = boats.id
        AND travel_trips.check_in #{period} AND travel_trips.status IN(0, 3)
        AND travel_trips.rental = #{Travel::Trip.rentals['shared']} LIMIT 1
    "

    @scope = scope.joins("LEFT JOIN travel_trips ON travel_trips.id = (#{trip_id_sql})")
    @scope = scope.where("(
      (travel_trips.id IS NULL AND boats.shared_check_in_time > #{date_time_db(available_check_in(date))}) OR
      travel_trips.number_of_guests < travel_trips.max_guests
    )")
  end

  def apply_blocked_period(from, to)
    rental_index = (Travel::BookingBlocking.rental_types.symbolize_keys)[rental]
    period = "BETWEEN '#{from.strftime("%Y-%m-%d")}' AND '#{to.strftime("%Y-%m-%d")}'"

    block_id_sql = "
      SELECT id FROM travel_booking_blockings where travel_booking_blockings.boat_id = boats.id AND
      (travel_booking_blockings.started_at #{period} OR travel_booking_blockings.finished_at #{period}) AND
      rental_type = #{rental_index} LIMIT 1
    "
    @scope = scope.joins("LEFT JOIN travel_booking_blockings ON travel_booking_blockings.id = (#{block_id_sql})")
    @scope = scope.where("travel_booking_blockings.id IS NULL")
  end

  def apply_min_passengers(min_passengers)
    size = min_passengers
    return if size.zero?

    if rental == :shared && params[:check_in].present?
      @scope.where!("
        (travel_trips.id IS NULL and boats.shared_max_passengers >= #{size})
        OR (travel_trips.id IS NOT NULL AND travel_trips.max_guests >= (travel_trips.number_of_guests + #{size}))
      ")
    else
      case rental
      when :shared then @scope.where!("boats.shared_max_passengers >= #{size}")
      else @scope.where!("boats.passengers_count >= #{size}")
      end
    end
  end

  def apply_min_and_max_prices(min, max)
    return if min.zero? && max.zero?

    return apply_classic_prices(min, max) if rental == :classic

    field = price_field
    tb_field = "boat.#{field}"

    if min.positive? && max.positive?
      @scope.where!(field => min...max)
    elsif min.positive?
      @scope.where!("#{tb_field} <= #{min}")
    elsif max.positive?
      @scope.where!("#{tb_field} >= #{min}")
    end
  end

  def price_field
    @price_field ||=  case rental
                      when :classic then :per_day
                      when :shared then :shared_price
                      when :sleepin then :sleepin_per_night
                      else raise ArgumentError, "Bad rental type"
                      end
  end

  def apply_classic_prices(min, max)
    sql = if min.positive? && max.positive?
          "(
            boats.per_half_day > 0 AND boats.per_half_day BETWEEN #{min} AND #{max}
            OR boats.per_half_day = 0 AND boats.per_day BETWEEN #{min} AND #{max}
          )"
        elsif min.positive?
          "(
            boats.per_half_day > 0 AND boats.per_half_day >= #{min}
            OR boats.per_half_day = 0 AND boats.per_day >= #{min}
          )"
        elsif max.positive?
          "(
            boats.per_half_day > 0 AND boats.per_half_day <= #{max}
            OR boats.per_half_day = 0 AND boats.per_day <= #{max}
          )"
        end
    return if sql.blank?

    @scope.where!(sql)
  end

  # for condition in boat fields, NOT in trip
  def available_check_in(check_in)
    return CHECK_IN_START_AT if check_in.to_date > Date.today

    # not available if date in the past
    return CHECK_IN_START_AT + 24.hours if check_in.to_date < Date.today

    min_from = CHECK_IN_START_AT + TravelService::Preference::PRE_BOOKING_MIN_TIME
    check_in_time = DateService.time_from_date_and_time(min_from, Time.zone.now)
    min_from > check_in_time ? min_from : check_in_time
  end

  def date_time_db(date)
    "'#{date.strftime("%Y-%m-%d %H:%M:%S")}'"
  end

  def date_db(date)
    "'#{date.strftime("%Y-%m-%d")}'"
  end

  def data_to_ids_array(data, key)
    ids_array = data[key]
    ids_array = ids_array.split(',') if data[key].is_a?(String)
    ids_array.map(&:to_i)
  end

end
