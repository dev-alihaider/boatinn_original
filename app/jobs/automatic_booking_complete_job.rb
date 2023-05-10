# frozen_string_literal: true

class AutomaticBookingCompleteJob < ApplicationJob
  def perform(booking_id)
    booking = Booking.find(booking_id)
    if booking.can_complete?
      booking.complete!
    end
  end
end
