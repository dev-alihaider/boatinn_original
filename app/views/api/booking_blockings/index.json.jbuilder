# frozen_string_literal: true

json.booking_blockings @booking_blockings, partial: 'booking_blocking', as: :booking_blocking
json.bookings @bookings, partial: 'booking', as: :booking

