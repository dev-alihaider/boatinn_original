class ReviewGivenJob < ApplicationJob

  def perform(review_id)
    @review = Review.find(review_id)
    reply_expire_date = Reviews::EXPIRATION_DAYS_REPLY.days.from_now
    @review.trip.boat.update(rating_hash: Reviews.get_rating_for_boat(@review.trip.boat))
    ReviewCloseJob.set(wait_until: reply_expire_date).perform_later(review_id)
    @review.travel? ? review_given_by_client : review_given_by_seller
  end

  def review_given_by_seller
    if @review.receiver_review_done?
      NotifyService.read_boat_owner_review(@review)
    else
      NotifyService.boat_owner_has_left_review(@review)
    end
  end

  def review_given_by_client
    if @review.receiver_review_done?
      NotifyService.read_client_review(@review)
    else
      NotifyService.client_has_left_review(@review)
    end
  end

end