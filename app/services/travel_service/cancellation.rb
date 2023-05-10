module TravelService::Cancellation
  module_function

  def cancellation_process(trip, booking_model)
    case trip.cancellation.to_sym
    when :strict
      TravelService::Cancellation::StrictProcess.new(booking_model)
    when :flexible
      TravelService::Cancellation::FlexibleProcess.new(booking_model)
    when :moderate
      TravelService::Cancellation::ModerateProcess.new(booking_model)
    else
      raise StandardError.new("Bad cancellation policy!")
    end
  end

  def authorize_period?(booking)
    TravelService::Preference.authorize_period?(booking)
  end

  def will_refund_from_travel(travel)
    return money_zero(travel.trip.currency) if travel.current_bookings.blank?
    will_refund_from_bookings(travel.current_bookings)
  end

  def will_refund_from_bookings(bookings)
    bookings.sum{ |book| will_refund_form_booking(book) }
  end

  def will_refund_form_booking(booking)
    return money_zero(booking.currency) if booking.payments.paid.blank?
    booking.payments.paid.sum{ |payment| will_refund_from_payment(payment) }
  end

  def will_refund_from_payment(payment)
    return money_zero(payment.currency) unless payment.paid?
    return payment.total if authorize_period?(payment.booking)
    cancel_process = cancellation_process(payment.booking.trip, payment.booking)
    cancel_process.will_refund_from_payment(payment)
  end

  def cancel_travel!(travel, subject: nil, reason: nil)
    refund_all = travel.current_user_seller?
    refund = refund_all ? travel.paid_amount : will_refund_from_travel(travel)

    travel.current_bookings.each{ |book| cancel_booking!(book, refund_all) }
    travel.trip.create_trip_cancellation(
      seller: travel.current_user_seller?,
      refunded: refund,
      subject: subject,
      reason: reason,
      penalty_cents: 0
    )

    cancellation = travel.trip.trip_cancellation
    is_seller = travel.current_user_seller?

    TravelService::Transition.travel_canceled(travel, reason)
    TravelService::Penalization.setup_owner_penalty(cancellation) if is_seller

    Result::Success.new(travel)
  rescue
    Result::Error.new(travel)
  end

  def cancel_booking!(booking, refund_all)
    refunded = booking.payments.paid.all? do |payment|
      cancel_payment!(payment, refund_all)
    end
    booking.update(status: :closed) if refunded
  end

  def cancel_payment!(payment, refund_all)
    refund_amount =
      if refund_all
        payment.total
      else
        cancel_process = cancellation_process(payment.booking.trip, payment.booking)
        cancel_process.will_refund_from_payment(payment)
      end
    PaymentService.cancel_payment(payment, refund_amount: refund_amount)
  end

  def money_zero(currency)
    Money.new(0, currency)
  end

end

