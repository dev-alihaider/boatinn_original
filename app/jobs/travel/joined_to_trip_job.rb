# frozen_string_literal: true

class Travel::JoinedToTripJob < ApplicationJob

  def perform(booking_id)
    booking = Travel::Booking.find(booking_id)
    ::NotifyService.booking_joined_to_seller(booking)
    ::NotifyService.booking_joined_to_client(booking)
  end

end
