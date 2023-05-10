class ReviewExpiredJob < ApplicationJob

  def perform(review_id)
    review = Review.find_by(id: review_id)
    return if review.blank?

    if review.pending?
      review.expired!
      Review.find_by(sender: review.receiver, trip: review.trip).update(receiver_review_done: true)
      review.trip.boat.update(rating_hash: Reviews.get_rating_for_boat(review.trip.boat))
    end

  end

end