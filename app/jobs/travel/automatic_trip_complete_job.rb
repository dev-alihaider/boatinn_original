# frozen_string_literal: true

class Travel::AutomaticTripCompleteJob < ApplicationJob

  def perform(trip_id)
    trip = Travel::Trip.find(trip_id)
    trip.complete! if trip.can_complete?
  end

end
