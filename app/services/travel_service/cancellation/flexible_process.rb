module TravelService::Cancellation
  class FlexibleProcess < BaseProcess

    def refund_period?
      days_before_checkin(@booking) > FLEXIBLE_MIN_DAYS
    end

  end
end
