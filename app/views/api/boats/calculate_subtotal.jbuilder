json.unit_price             view_money @travel.unit_price
json.subtotal               view_money @travel.subtotal
json.client_fee             view_money @travel.client_fee
json.total                  view_money @travel.total
json.per_quantity           @travel.number_of_periods
json.passenger_quantity     @travel.number_of_guests
json.rental_type            @travel.trip.rental
json.min                    @travel.trip.min_guests
json.max                    @travel.trip.max_guests
json.person_price           view_money @travel.subtotal / @travel.number_of_guests
json.guest_label            @travel.guest_label
json.cleaning_fee           (view_money @travel.trip.cleaning_fee).to_s
json.skipper_fee            (view_money @travel.trip.skipper_fee).to_s
json.skipper_included       @travel.trip.skipper_included?
json.minimum_rental_time    @travel.trip.boat.minimum_rental_time.to_i
json.booking_available_from TravelService::Validator.booking_available_from(@travel.trip).strftime("%Y-%m-%d")

if @travel.will_be_pay_deposit_amount.positive?
  json.will_be_pay_deposit_amount view_money(@travel.will_be_pay_deposit_amount)
end

if @travel.paid_amount.positive?
  json.paid_amount view_money(@travel.paid_amount)
end
