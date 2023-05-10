class AddTransferDateToBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :transfer_at, :datetime
  end
end
