class ListingImageUpdatedJob < ApplicationJob

  def perform(boat_id)
    boat = Boat.find(boat_id)
    NotifyService.boat_image_updated(boat)
  end

end