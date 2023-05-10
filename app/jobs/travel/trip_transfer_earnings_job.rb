# frozen_string_literal: true

class Travel::TripTransferEarningsJob < ApplicationJob

  def perform(trip_id)
    trip = ::Travel::Trip.find(trip_id)
    return if trip.declined? || trip.aborted? || trip.pending?

    trip.bookings.open.each do |booking|
      booking.payments.paid.each do |payment|
        PaymentTransferJob.perform_now(payment.id)
      end
    end
  end

end
