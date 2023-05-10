# frozen_string_literal: true

class DestroyOutdatedBookingBlockingsJob < ApplicationJob # :nodoc:
  queue_as :default

  def perform
    Travel::BookingBlocking.outdated.destroy_all
  end
end
