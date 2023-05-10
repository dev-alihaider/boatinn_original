class Travel::CancelBooking < Trailblazer::Operation

  step :ensure_booking_end_refund_type
  step :cancel_payments!
  step :close_booking!

  def ensure_booking_end_refund_type(skill, **)
    return fail('booking not set') if skill[:params][:booking].blank?
    return fail('refund type not set') if skill[:params][:refund_type].blank?

    @refund_type = skill[:params][:refund_type]
    @booking = skill[:params][:booking]
  end

  def cancel_payments!(*)
    @booking.payments.paid.each do |payment|
      cancel_params =  { payment: payment, refund_type: @refund_type }
      sub_result = Travel::CancelPayment.(params: cancel_params)
      return fail("can`t cancel payment - #{payment.id}") if sub_result.failure?
    end
  end

  def close_booking!(*)
    @booking.update(status: :closed)
  end

end
