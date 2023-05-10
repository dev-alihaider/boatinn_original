class AddBoatNameToBooking < ActiveRecord::Migration[5.1]
  def up
    add_column :bookings, :boat_name, :string, index: true

    Booking.find_each do |booking|
      booking.update_column(:boat_name, booking.boat.listing_title)
    end
  end

  def down
    remove_column :bookings, :boat_name
  end
end
