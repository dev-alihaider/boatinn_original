class ListingCreatedJob < ApplicationJob

  def perform(listing_id)
    boat = Boat.find(listing_id)
    if boat.finished?
      ListingFinishedJob.perform_now(boat.id)
    else
      ListingNotCompletedJob.set(wait_until: 24.hours.from_now).perform_later(boat.id)
    end
  end

end