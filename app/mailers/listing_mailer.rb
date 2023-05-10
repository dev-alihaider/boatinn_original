class ListingMailer < ApplicationMailer
  add_template_helper(ListingsHelper)

  def boat_finished_without_payment(boat)
    user_email boat.user do |email|
      subject = t("listing_mailer.boat_finished_without_payment.subject")
      mail(to: email, subject: subject)
    end
  end

  def boat_finished_without_cv(boat)
    user_email boat.user do |email|
      subject = t("listing_mailer.boat_finished_without_cv.subject")
      mail(to: email, subject: subject)
    end
  end

  def boat_offlined(boat)
    @boat = boat
    user_email boat.user do |email|
      subject = t("listing_mailer.boat_offlined.subject")
      mail(to: email, subject: subject)
    end
  end

  def boat_image_updated(boat)
    @boat = boat
    user_email boat.user do |email|
      subject = t("listing_mailer.boat_image_updated.subject")
      mail(to: email, subject: subject)
    end
  end

  def boat_not_completed(boat)
    @boat = boat
    user_email boat.user do |email|
      @locals = { listing_title: boat.listing_title }
      subject = t("listing_mailer.boat_not_completed.subject", @locals)
      mail(to: email, subject: subject)
    end
  end

end
