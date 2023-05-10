# frozen_string_literal: true

class Travel::SharedActivatedJob < ApplicationJob

  def perform(booking_id)
    booking = ::Travel::Booking.find(booking_id)
    ::NotifyService.booking_joined_to_client(booking)
    ::NotifyService.booking_shared_activated_to_seller(booking)
  end

end
