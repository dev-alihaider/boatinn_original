# frozen_string_literal: true

json.array! @bookings, partial: 'users/listings/show/booking', as: :booking
