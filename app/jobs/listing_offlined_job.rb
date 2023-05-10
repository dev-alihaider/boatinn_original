class ListingOfflinedJob < ApplicationJob

  def perform(listing_id)
    boat = Boat.find(listing_id)
    NotifyService.listing_offlined(boat)
  end

end