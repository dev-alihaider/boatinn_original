# frozen_string_literal: true

class Travel::TripCreatedJob < ApplicationJob

  def perform(trip_id)
    trip = ::Travel::Trip.find(trip_id)
    ::Travel::AutomaticTripCompleteJob.set(wait_until: trip.transfer_at).perform_later(trip_id)
    ::Travel::TripFinishedJob.set(wait_until: trip.check_out).perform_later(trip_id)
    ::Travel::TripTransferEarningsJob.set(wait_until: trip.transfer_at).perform_later(trip_id)
  end

end
