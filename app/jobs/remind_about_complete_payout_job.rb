class RemindAboutCompletePayoutJob < ApplicationJob

  def perform(listing_id)
    boat = Boat.find(listing_id)
    NotifyService.boat_finished_without_cv(boat) unless boat.user.cv_completed?
  end

end