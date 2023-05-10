class ReviewRemindForClientJob < ApplicationJob

  def perform(trip_id, client_id)
    trip = Travel::Trip.find(trip_id)
    client = User.find(client_id)

    unless Reviews.review_given?(client, trip)
      NotifyService.client_should_leave_review(trip, client)
    end
   end
end