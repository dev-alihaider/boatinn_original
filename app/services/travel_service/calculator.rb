module TravelService::Calculator

  class << self

    # calculate subtotal and assign cleaning and skipper fee
    def calculate_subtotal(trip)
      subtotal = basic_subtotal(trip)

      if trip.shared?
        subtotal *= trip.number_of_guests
      elsif trip.sleepin?
        extra_guests = trip.number_of_guests - trip.boat.sleepin_extra_guests
        if extra_guests.positive?
          extra_guests_cents = (trip.boat.sleepin_extra_price * extra_guests * 100)
          subtotal += Money.new(extra_guests_cents, trip.currency)
        end
      end

      trip.cleaning_fee = calculate_cleaning_fee(trip)
      trip.skipper_fee  = calculate_skipper_fee(trip)
      subtotal
    end

    def calculate_skipper_fee(trip)
      skipper_acceptance_rentals = %w[half_day one_day night]
      zero = Money.new(0, trip.currency)
      return zero unless trip.skipper_included?
      return zero unless skipper_acceptance_rentals.include?(trip.rental)
      return zero if trip.boat.skipper.to_f.zero?

      fee_cents = trip.boat.skipper.to_f * trip.number_of_period * 100
      Money.new(fee_cents, trip.currency)
    end

    def calculate_cleaning_fee(trip)
      cleaning_acceptance_rentals = %w[half_day one_day night sleepin]
      zero = Money.new(0, trip.currency)
      return zero unless cleaning_acceptance_rentals.include?(trip.rental)
      return zero if trip.boat.cleaning_fee.to_f.zero?

      Money.new(trip.boat.cleaning_fee.to_f * 100, trip.currency)
    end

    private

    def basic_subtotal(trip)
      if trip.week? || (trip.night? && trip.number_of_period > 6)
        calculate_for_weeks(trip)
      else
        calculate_for_period(trip)
      end
    end

    def calculate_for_weeks(trip)
      start_week = trip.check_in
      end_week = start_week + 6.days

      subtotal = 0

      # calculate full weeks
      while end_week < trip.check_out
        subtotal += trip.boat.price_cents_for_week(start_week)
        start_week = end_week + 1.day
        end_week = start_week + 6.days
      end

      # calculate days of last week by weekly price
      next_day = start_week
      while next_day < trip.check_out - 1.day
        per_season_price = trip.boat.season_rates.for_date(next_day).first
        subtotal += (per_season_price&.per_week || trip.boat.per_week) / 7
        next_day += 1.day
      end

      Money.new(subtotal * 100, trip.currency)
    end

    def calculate_for_period(trip)
      first_day = trip.check_in.to_date
      last_day = trip.check_out.to_date
      last_day -= 1.day if %w[night sleepin].include?(trip.rental)

      price_cents = 0

      (first_day..last_day).each do |day|
        price_cents += trip.boat.price_cents_for(trip.rental, date: day)
      end

      Money.new(price_cents, trip.currency)
    end

  end
end
