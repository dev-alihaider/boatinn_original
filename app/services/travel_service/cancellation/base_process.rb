module TravelService::Cancellation
  class BaseProcess

    include TravelService::Preference

    def initialize(booking_model)
      @booking = booking_model
    end

    def will_refund_from_payment(payment)
      refund_period? ? payment.subtotal_with_fee : payment.cleaning_fee
    end

    def can_cancel?
      @booking.end_at > Time.zone.now
    end

    def nought
      Money.new(0, @booking.currency)
    end

    def refund_period?
      raise StandardError, 'check for refund period can be in base cancellation process'
    end

  end
end
