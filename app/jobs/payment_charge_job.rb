# frozen_string_literal: true

class PaymentChargeJob < ApplicationJob

  def perform(payment_id)
    @payment = Travel::Payment.find(payment_id)
    return false if @payment.blank?
    return unless @payment.intent_pending?

    result = StripeApi.intentize_payment!(@payment, capture: true, offline: true)
    if result.success?
      # mark payment as urgent if need online confirmation
      if payment.requires_online_confirmation?
        payment.update(urgent: true)
      end
    else
      payment_not_charged
    end
  rescue
    payment_not_charged
  end


  def payment_not_charged
    # send email about fail payment to payer
    NotifyService.notify_about_insufficient_funds(@payment)
    # try again when attept period
    passed_time = Time.zone.now.to_i - @payment.plan_charge_at.to_i
    if TravelService::Preference::ATTEMPT_TO_PAY_DURATION.to_i > passed_time
      # mark payment as urgent
      @payment.update(urgent: true)
      wait_until = TravelService::Preference::ATTEMPT_TO_PAY_INTERVAL.from_now
      PaymentChargeJob.set(wait_until: wait_until).perform_later(@payment.id)
    else
      # cancel booking as client
      Travel::CancelTrip.(params: { trip: @payment.booking.trip, canceller: @payment.booking.client })
    end
  end
end
