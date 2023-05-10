module TravelService::Cancellation
  class StrictProcess < BaseProcess

    def refund_period?
      days_before_checkin(@booking) > STRICT_MIN_DAYS
    end

  end
end
