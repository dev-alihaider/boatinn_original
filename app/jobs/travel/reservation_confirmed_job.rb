# frozen_string_literal: true

class Travel::ReservationConfirmedJob < ApplicationJob

  def perform(booking_id)
    booking = ::Travel::Booking.find(booking_id)
    ::NotifyService.booking_confirmed_to_client(booking)
    ::NotifyService.booking_confirmed_to_seller(booking)
  end

end
