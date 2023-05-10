# frozen_string_literal: true

json.array! @booking_blockings, partial: 'users/listings/show/booking_blocking', as: :booking_blocking
