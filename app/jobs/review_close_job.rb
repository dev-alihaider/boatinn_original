class ReviewCloseJob < ApplicationJob

  def perform(review_id)
    review = Review.find(review_id)
    review.closed! if review.reviewed?
  end

end