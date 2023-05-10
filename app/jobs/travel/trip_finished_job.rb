# frozen_string_literal: true

class Travel::TripFinishedJob < ApplicationJob

  def perform(trip_id)
    trip = ::Travel::Trip.find(trip_id)
    return if trip.declined? || trip.aborted?
    CreatePendingReviewsJob.perform_now(trip_id)

    review_remind_at = NotifyService::REMIND_ABOUT_LEAVE_REVIEW.from_now
    trip.customers.enabled.each do |customer|
      ReviewRemindForClientJob.set(wait_until: review_remind_at).perform_later(trip_id, customer.client_id)
    end

    ReviewRemindForSellerJob.set(wait_until: review_remind_at).perform_later(trip_id)
  end

end
