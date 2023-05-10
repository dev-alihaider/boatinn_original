class ReviewMailer < ApplicationMailer

  # to client
  def boat_owner_has_left_review(review)
    @review = review
    @review_responce = Review.find_by(trip_id: @review.trip_id, sender_id: @review.receiver_id)
    user_email review.receiver do |email|
      @locals = { seller_name: @review.sender.display_name }
      mail(to: email, subject: t("review_mailer.boat_owner_has_left_review.subject", @locals))
    end
  end

  # to client
  def read_boat_owner_review(review)
    @review = review
    user_email review.receiver do |email|
      @locals = { seller_name: review.sender.display_name }
      mail(to: email, subject: t("review_mailer.read_boat_owner_review.subject", @locals))
    end
  end

  # to client
  def client_should_leave_review(trip, client)
    user_email client do |email|
      @locals = { client_name: client.display_name }
      @review = Review.travel.find_by(sender: client, trip_id: trip.id)
      mail(to: email, subject: t("review_mailer.client_should_leave_review.subject", @locals))
    end
  end

  # to owner
  def boat_owner_should_leave_review(trip)
    user_email trip.seller do |email|
      @give_review_url = if trip.shared?
                           given_dashboard_reviews_url
                         else
                           review_id = Review.guest.find_by(sender_id: trip.seller_id, trip_id: trip.id).id
                           dashboard_review_leave_review_url(review_id: review_id)
                         end
      @locals = { seller_name: trip.seller.display_name, service_name: t('service_name') }
      mail(to: email, subject: t("review_mailer.boat_owner_should_leave_review.subject", @locals))
    end
  end

  # to owner
  def client_has_left_review(review)
    @review = review
    @review_responce = Review.find_by(trip_id: @review.trip_id, sender_id: @review.receiver_id)
    user_email review.receiver do |email|
      @locals = { client_name: review.sender.display_name }
      mail(to: email, subject: t("review_mailer.client_has_left_review.subject", @locals))
    end
  end

  # to owner
  def read_client_review(review)
    @review = review
    user_email review.receiver do |email|
      @locals = { client_name: review.sender.display_name }
      mail(to: email, subject: t("review_mailer.read_client_review.subject", @locals))
    end
  end

end