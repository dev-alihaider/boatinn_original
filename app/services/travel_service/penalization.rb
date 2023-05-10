module TravelService::Penalization

  class << self

    def setup_owner_penalty(cancellation)
      seller = cancellation.trip.seller
      penalization = Penalization.find_or_create_for(seller)
      unless penalization.penalty_period_available?
        setup_penalty_period_for(penalization, from_at: cancellation.created_at)
      end

      # number of cancellation for current_period
      current_cancellations = Penalization.current_canceled_trips_by_seller(seller).count

      times_size = TravelService::Preference::PENALIZATION_TIMES_SIZE_CENTS
      amount_cents = times_size[current_cancellations - 1 ] || times_size.last
      amount = Money.new(amount_cents, TravelService::Preference::PENALIZATION_PENALTY_CURRENCY)
      penalization.update(
        current_penalty: penalization.current_penalty + amount,
        current_cancellations: current_cancellations,
      )
      cancellation.update(penalty: amount)
    end

    private

    def setup_penalty_period_for(penalization, from_at:)
      penalization.update!(
        period_started_at: from_at,
        period_end_at: from_at + TravelService::Preference::PENALIZATION_PERIOD_DURATION
      )
    end

  end
end
