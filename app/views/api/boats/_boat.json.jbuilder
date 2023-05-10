# frozen_string_literal: true

json.extract! boat, :id, :listing_title, :passengers_count

json.wished current_user.present? && current_user.wishes.exists?(boat.id)

json.url listing_params_url(
  boat,
  rental_type: @rental_type,
  check_in_date: params[:check_in_date].presence,
  check_out_date: params[:check_out_date].presence,
  passengers_count: params[:passengers_count].presence
)

json.minimum_rental do
  json.rental I18n.t(boat.minimum_rental(@rental_type)[:rental])
  json.price in_current_currency_with_sym(boat.minimum_rental(@rental_type)[:price])
  json.passengers boat.minimum_rental(@rental_type)[:passengers]
end

json.image image_url(boat_image_url(boat, :medium))

json.prices do
  json.per_half_day in_current_currency_with_sym(boat.per_half_day)
  json.shared_price in_current_currency_with_sym(boat.shared_price)
  json.sleepin_per_night in_current_currency_with_sym(boat.sleepin_per_night)
end

json.location do
  json.name boat.location.short_name
  json.lat  boat.location.lat
  json.lng  boat.location.lng
end

json.rating do
  json.avg avg_boat_rating(boat)
  json.count boat.rating_hash[:count]
end
