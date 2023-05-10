class AddFeesToBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_bookings, :cleaning_fee_cents, :integer, default: 0
    add_column :travel_bookings, :skipper_fee_cents, :integer, default: 0
  end
end
