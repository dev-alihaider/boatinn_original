class ListingNotCompletedJob < ApplicationJob

  def perform(listing_id)
    boat = Boat.find(listing_id)
    NotifyService.boat_not_completed(boat) unless boat.finished?
  end

end