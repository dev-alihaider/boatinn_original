# frozen_string_literal: true

class PaymentCaptureJob < ApplicationJob

  def perform(payment_id)
    payment = ::Travel::Payment.find(payment_id)
    ::StripeApi.capture_payment(payment)
  end

end
