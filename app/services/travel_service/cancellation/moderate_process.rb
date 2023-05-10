module TravelService::Cancellation
  class ModerateProcess < BaseProcess

    def will_refund_from_payment(payment)
      if refund_period_force?
        force_refund_amount(payment)
      elsif refund_period?
        payment.subtotal_with_fee
      else
        payment.cleaning_fee
      end
    end

    def refund_period_force?
      refund_period? && days_before_checkin(@booking) < MODERATE_FORCE_DAYS
    end

    def refund_period?
      days_before_checkin(@booking) > MODERATE_MIN_DAYS
    end

    # 50% + 100% cleaning fee
    def force_refund_amount(payment)
      subtotal = payment.subtotal_with_fee - payment.cleaning_fee
      subtotal.percent_of(MODERATE_FORCE_PERCENT) + payment.cleaning_fee
    end
  end
end
