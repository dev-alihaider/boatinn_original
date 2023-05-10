# frozen_string_literal: true

class Travel::TripCanceledJob < ApplicationJob

  def perform(trip_id, canceller_id)
    trip = Travel::Trip.find(trip_id)
    canceller_client = !trip.trip_cancellation.seller?

    travel = TravelService::Travel.new(trip, User.find(canceller_id))
    booking = travel.closed_bookings.first

    # when canceller is client
    if canceller_client
      if trip.shared?
        NotifyService.booking_left_to_seller(booking)
      else
        NotifyService.booking_canceled_by_client_to_seller(booking)
      end
      # when canceller is seller
    else
      NotifyService.booking_canceled_by_seller_to_client(booking)
    end
    # always send client report about cancellation
    NotifyService.cancellation_report_to_client(booking)
  end

end
