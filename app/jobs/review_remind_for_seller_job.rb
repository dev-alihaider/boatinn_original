class ReviewRemindForSellerJob < ApplicationJob

  def perform(trip_id)
    trip = Travel::Trip.find(trip_id)

    unless Reviews.review_given?(trip.seller, trip)
      NotifyService.boat_owner_should_leave_review(trip)
    end
  end
end