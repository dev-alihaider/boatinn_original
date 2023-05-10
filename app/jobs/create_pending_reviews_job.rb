# frozen_string_literal: true

class CreatePendingReviewsJob < ApplicationJob

  def perform(trip_id)
    trip = Travel::Trip.find(trip_id)
    expire_date = Reviews::EXPIRATION_DAYS_REVIEW.days.from_now
    trip.customers.where(left_at: nil).find_each do |customer|
      r1 = create_pending_review_for_client(trip, customer)
      r2 = create_pending_review_for_seller(trip, customer)
      ReviewExpiredJob.set(wait_until: expire_date).perform_later(r1.id)
      ReviewExpiredJob.set(wait_until: expire_date).perform_later(r2.id)
    end
  end

  def create_pending_review_for_seller(trip, customer)
    Review.create(
      sender: trip.seller,
      receiver: customer.client,
      trip: trip,
      status: :pending,
      target: :guest
    )
  end

  def create_pending_review_for_client(trip, customer)
    Review.create!(
      sender: customer.client,
      receiver: trip.seller,
      trip: trip,
      status: :pending,
      target: :travel
    )
  end

end