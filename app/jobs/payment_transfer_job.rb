class PaymentTransferJob < ApplicationJob

  def perform(payment_id)
    payment = Travel::Payment.find(payment_id)
    return unless payment.can_transfer?

    if StripeApi.transfer_payment(payment).success?
      ::NotifyService.owner_got_earnings(payment)
    else
      PaymentTransferJob.set(wait_until: 2.hours.from_now).perform_later(payment_id)
    end
  end

end
