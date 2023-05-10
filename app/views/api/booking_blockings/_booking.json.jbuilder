# frozen_string_literal: true

json.booking do
  json.id      booking.id
  json.trip_id booking.trip_id
end

json.trip do
  json.check_in  booking.trip.check_in.to_date
  json.check_out booking.trip.check_out.to_date
  json.rental    booking.trip.rental
end

json.conversation_url dashboard_inbox_url(id: booking.trip.id)

json.client do
  json.name user_name(booking.client)
  json.photo user_image_url(booking.client)
  json.profile_url show_profile_url(id: booking.client, locale: locale)
end
