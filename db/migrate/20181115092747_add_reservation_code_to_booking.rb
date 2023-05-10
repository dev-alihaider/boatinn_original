class AddReservationCodeToBooking < ActiveRecord::Migration[5.1]
  include BookingService::Preference
  def change
    add_column :bookings, :reservation_code, :string

    Booking.find_each do |book|
      reservation_code = generate_reservation_code
      book.update(reservation_code: reservation_code)
    end

    add_index :bookings, :reservation_code, unique: true
  end
end
