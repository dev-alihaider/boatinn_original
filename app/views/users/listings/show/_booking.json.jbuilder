# frozen_string_literal: true

json.check_in  booking.trip.check_in.to_date
json.check_out booking.trip.check_out.to_date
json.rental    booking.trip.rental
json.free_seats booking.trip.max_guests - booking.trip.number_of_guests
