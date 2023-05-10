# frozen_string_literal: true
module TravelService::Validator

  class << self
    # build new travel with trip, with booking and payments(!without save)
    def initiate_new_travel(params, client)
      result = initiate_new_trip(params)
      return result unless result[:success]
      trip = result[:data]
      booking = build_booking_for(trip, client)

      travel = TravelService::Travel.new(result[:data], client)
      travel.attach_current_bookings([booking])
      travel.attach_payments(booking.paying_process.build_payments)
      travel.attach_current_customer(build_customer_for(booking, client))
      Result::Success.new(travel)
    # rescue
    #   Result::Error.new(:travel)
    end

    def initiate_new_trip(params)
      parse_params = ParserParams.new(params)

      # boat
      boat = Boat.find_by(id: parse_params.boat_id)
      return Result::Error.new(:boat_ensure, params) unless boat.present?

      # rental
      trip = Travel::Trip.new(boat: boat, status: :pending, seller: boat.user)
      trip.rental           = parse_params.rental_type
      trip.skipper_included = parse_params.skipper_included(boat)
      return Result::Error.new(:rental, params) if trip.rental.blank?

      # dates and quantity
      quantity = OrderPeriodQuantity.new(trip, parse_params.start_at, parse_params.end_at)
      trip.check_in         = quantity.rental_start_at
      trip.check_out        = quantity.rental_end_at
      trip.max_guests       = boat.max_passenger_capacity_for(trip.rental, trip.check_in)
      trip.min_guests       = boat.min_passenger_capacity_for(trip.rental, trip.check_in)
      trip.number_of_guests = passenger_quantity(trip, parse_params)
      trip.number_of_period = quantity.quantity.zero? ? 1 : quantity.quantity

      return Result::Error.new(:dates, trip) if booking_available_from(trip) > trip.check_in
      return Result::Error.new(:dates, trip) unless dates_available?(trip)

      # prices
      order = OrderTotal.new(trip)

      trip.per_price        = order.unit_price
      trip.subtotal         = order.subtotal
      trip.seller_fee       = order.seller_fee
      trip.client_fee       = order.client_fee
      trip.service_fee      = order.service_fee
      trip.earnings         = order.earnings
      trip.total            = order.total
      trip.currency         = order.currency
      trip.vat_fee_percents = order.vat_fee_percents

      # cancellation
      trip.cancellation = boat.cancellation

      # when will be transfer earnings to seller
      trip.transfer_at = transfer_date_for(trip)

      assign_boat_details(trip)
      Result::Success.new(trip)
    # rescue
    #   Result::Error.new(:initiate, params)
    end

    # date from now, when booking will be available
    def booking_available_from(trip)
      pre_time = TravelService::Preference::PRE_BOOKING_MIN_TIME
      available_from = Time.zone.now + pre_time
      available_from > trip.check_in ? available_from : trip.check_in
    end

    # check free dates for new booking
    def dates_available?(trip)
      # check locked dates
      locked_exists = Travel::BookingBlocking
                        .where(boat_id: trip.boat_id)
                        .where(rental_type: trip.rental_group)
                        .within_dates(trip.check_in, trip.check_out)
                        .exists?
      return false if locked_exists

      # check booked dates
      date_range = trip.check_in..trip.check_out
      booked_trips = Travel::Trip.approved
                        .where(boat_id: trip.boat_id, check_in: date_range)
                        .or(Travel::Trip.approved.where(boat_id: trip.boat_id, check_out: date_range))
      return true if booked_trips.blank?

      booked_trips.each do |booked_trip|
        return (trip.shared? && booked_trip.shared?)
      end
    end

    def build_booking_for(trip, client)
      trip.bookings.new(
        client_id: client.id,
        number_of_guests: trip.number_of_guests,
        number_of_period: trip.number_of_period,
        payment_process: initiate_payment_process(trip),
        status: :open,
        per_price: trip.per_price,
        client_fee: trip.client_fee,
        seller_fee: trip.seller_fee,
        service_fee: trip.service_fee,
        cleaning_fee: trip.cleaning_fee,
        skipper_fee: trip.skipper_fee,
        earnings: trip.earnings,
        subtotal: trip.subtotal,
        total: trip.total,
        currency: trip.currency
      )
    end

    def build_customer_for(booking, client)
      booking.trip.customers.new(
        trip_id: booking.trip_id,
        client_id: client.id,
        number_of_guests: booking.number_of_guests,
        number_of_period: booking.number_of_period,
        per_price: booking.per_price,
        client_fee: booking.client_fee,
        seller_fee: booking.seller_fee,
        service_fee: booking.service_fee,
        cleaning_fee: booking.cleaning_fee,
        skipper_fee: booking.skipper_fee,
        earnings: booking.earnings,
        subtotal: booking.subtotal,
        total: booking.total,
        currency: booking.currency
      )
    end

    def assign_boat_details(trip)
      trip.boat_hash = {} if trip.boat_hash.blank?

      if trip.boat.images.present?
        image_path = trip.boat.images.order(:priority).first.attachment.path
        trip.image = File.new(image_path)
      end

      location = trip.boat.location
      if location.present?
        trip.boat_hash[:location] = {
          address: location.name,
          name: location.short_name,
          lat: location.lat.to_f,
          lng: location.lng.to_f,
        }
      end

      trip.boat_hash[:name] = trip.boat.listing_title
    end

    def initiate_payment_process(trip)
      count_days = DateService.duration_in_days(Time.zone.now, trip.check_in)
      count_days -= 1 # today
      if count_days > TravelService::Preference::TRIPLE_DAYS_BEFORE_START
        :triple
      elsif count_days >= TravelService::Preference::DUAL_DAYS_BEFORE_START
        :dual
      else
        :single
      end
    end

    def passenger_quantity(trip, parse_params)
      quantity = parse_params.passengers_count
      min = trip.min_guests
      max = trip.max_guests
      (min <= quantity && quantity <= max) ? quantity : min
    end

    def transfer_date_for(trip)
      if trip.seller.completed_reservation?
        trip.check_in + TravelService::Preference::TRANSFER_DELAY
      else
        trip.check_in + TravelService::Preference::FIRST_TRANSFER_DELAY
      end
    end

  end

  class OrderPeriodQuantity
    def initialize(trip, start_at, end_at)
      @trip     = trip
      @start_at = DateService.parse(start_at)
      @end_at   = DateService.parse(end_at)
    end

    def quantity
      @quantity ||= begin
        case @trip.rental.to_sym
        when :half_day, :shared
          1
        when :one_day
          (DateService.duration_in_days(@start_at, @end_at)).to_i
        when :night, :sleepin
          (DateService.duration_in_days(@start_at, @end_at) -1).to_i
        when :week
          (DateService.duration_in_weeks(@start_at, @end_at)).to_i
        end
      end
    end

    def rental_start_at
      case @trip.rental.to_sym
      when :half_day, :one_day, :night, :week
        DateService.time_from_date_and_time(@start_at, @trip.boat.check_in_time)
      when :sleepin
        DateService.time_from_date_and_time(@start_at, @trip.boat.sleepin_check_in_time)
      when :shared
        DateService.time_from_date_and_time(@start_at, @trip.boat.shared_check_in_time)
      end
    end

    def rental_end_at
      case @trip.rental.to_sym
      when :half_day
        DateService.time_from_date_and_time(@start_at, @trip.boat.check_out_time)
      when :one_day
        DateService.time_from_date_and_time(@end_at, @trip.boat.check_out_time)
      when :night
        DateService.time_from_date_and_time(@end_at, @trip.boat.check_out_time)
      when :sleepin
        DateService.time_from_date_and_time(@end_at, @trip.boat.sleepin_check_out_time)
      when :shared
        DateService.time_from_date_and_time(@start_at, @trip.boat.shared_check_out_time)
      when :week
        DateService.time_from_date_and_time(@end_at, @trip.boat.check_out_time)
      end
    end
  end

  class ParserParams

    def initialize(params)
      @params = params
    end

    def boat_id
      @params[:travel_trip].present? ? @params[:travel_trip][:boat_id] : @params[:boat_id]
    end

    def rental_type
      if @params[:travel_trip].present?
        @params[:travel_trip][:rental]
      else
        ::Travel::Trip.rentals.invert[@params[:price_type].to_i - 1]
      end
    end

    def skipper_included(boat)
      case boat.captain.to_s.to_sym
      when :without
        false
      when :with
        true
      else
        @params[:skipper_included] = @params[:skipper_included] == 'true' ? true : false
      end
    end

    def start_at
      @params[:travel_trip].present? ? @params[:travel_trip][:check_in] : @params[:dateFrom]
    end

    def end_at
      (@params[:travel_trip].present? ? @params[:travel_trip][:check_out] : @params[:dateTo]) || start_at
    end

    def passengers_count
      (@params[:travel_trip].present? ? @params[:travel_trip][:number_of_guests] : @params[:passengers_count]).to_i
    end

  end

  class OrderTotal
    include TravelService::Preference
    def initialize(trip)
      trip.currency = currency
      @trip = trip
      subtotal
    end

    def unit_price
      @unit_price ||= Money.new(@trip.boat.price_cents_for(@trip.rental), currency)
    end

    def subtotal
      @subtotal ||= TravelService::Calculator.calculate_subtotal(@trip)
    end

    def total
      @total ||= subtotal_with_additional_fees + client_fee
    end

    def earnings
      @transfer ||= subtotal_with_additional_fees - seller_fee
    end

    def service_fee
      @service_fee ||= client_fee + seller_fee
    end

    def client_fee
      @client_fee ||= commission_from_client(subtotal_with_additional_fees)
    end

    def seller_fee
      @seller_fee ||= commission_from_seller(subtotal_with_additional_fees)
    end

    def subtotal_with_additional_fees
      @subtotal_with_additional_fees ||= [subtotal, @trip.cleaning_fee, @trip.skipper_fee].sum
    end
  end

end
