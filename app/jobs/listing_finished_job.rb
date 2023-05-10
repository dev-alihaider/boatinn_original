class ListingFinishedJob < ApplicationJob

  def perform(listing_id)
    payout_remind_at = NotifyService::REMIND_ABOUT_PAYOUT_DETAILS.from_now
    your_cv_remind_at = NotifyService::REMIND_ABOUT_YOUR_CV.from_now

    RemindAboutCompletePayoutJob.set(wait_until: payout_remind_at).perform_later(listing_id)
    RemindAboutCompleteCvJob.set(wait_until: your_cv_remind_at).perform_later(listing_id)
  end

end