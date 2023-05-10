class Travel::CancelPayment < Trailblazer::Operation

  step :ensure_payment_and_refund_type
  step :calculate_refund_amount
  step :make_refund!

  def ensure_payment_and_refund_type(skill, **)
    return fail('payment not set')     if skill[:params][:payment].blank?
    return fail('refund type not set') if skill[:params][:refund_type].blank?

    @payment, @refund_type = skill[:params][:payment], skill[:params][:refund_type]
  end

  def calculate_refund_amount(*)
    @refund_amount =
      if @refund_type.to_sym == :all
        @payment.total
      else
        cancel_process = TravelService::Cancellation.cancellation_process(@payment.booking.trip, @payment.booking)
        cancel_process.will_refund_from_payment(@payment)
      end
  end

  def make_refund!(*)
    result = StripeApi.cancel_payment(@payment, refund_amount: @refund_amount)
    result ? true : fail('payment can not make refund')
  end

end
