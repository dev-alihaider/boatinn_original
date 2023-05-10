# frozen_string_literal: true

class PaymentAuthorizedJob < ApplicationJob

  def perform(payment_id)
    # automatic capture after 24 hours
    PaymentCaptureJob.set(wait_until: 24.hours.from_now).perform_later(payment_id)
  end

end
