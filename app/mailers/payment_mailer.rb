class PaymentMailer < ApplicationMailer

  def notify_about_insufficient_funds(payment)
    @payment = payment
    @travel = TravelService::Travel.new(payment.booking.trip, payment.booking.client)
    @locals = { recipient_name: @payment.booking.client.display_name }

    user_email payment.booking.client do
      subject = t("payment_mailer.notify_about_insufficient_funds.subject", @locals)
      mail(to: payment.booking.client.email, subject: subject)
    end
  end

  def credit_card_added(card)
    user_email card.user do
      subject = t("payment_mailer.credit_card_added.subject")
      mail(to: @recipient.email, subject: subject)
    end
  end

  def owner_got_earnings(payment)
    @payment = payment
    user_email payment.booking.trip.seller do
      @locals = { seller_name: payment.booking.trip.seller.display_name }
      subject = t("payment_mailer.owner_got_earnings.subject", @locals)
      mail(to: @recipient.email, subject: subject)
    end
  end

end
