class ListingUpdatedJob < ApplicationJob

  def perform(listing_id, just_finished = nil)
    @boat = Boat.find(listing_id)
    ListingFinishedJob.perform_now(listing_id) if just_finished

    boat_offlined if @boat.offlined?
  end

  def boat_offlined
    interval_offlined = 1.hour
    key_offlined = "boat_offlined_#{@boat.id}"
    return if $redis.get(key_offlined)

    ListingOfflinedJob.set(wait_until: interval_offlined.from_now).perform_later(@boat.id)
    $redis.set(key_offlined, true, ex: interval_offlined)
  end

end