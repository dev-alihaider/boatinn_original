class RemindAboutCompleteCvJob < ApplicationJob

  def perform(listing_id)
    boat = Boat.find(listing_id)
    NotifyService.boat_finished_without_payment(boat) if boat.user.user_payouts.blank?
  end

end