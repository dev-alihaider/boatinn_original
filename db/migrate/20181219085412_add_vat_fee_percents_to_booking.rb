class AddVatFeePercentsToBooking < ActiveRecord::Migration[5.1]
  # include BookingService::Preference

  def up
    add_column :bookings, :vat_fee_percents, :decimal, precision: 5, scale: 2, default: 0
    # Booking.update_all(vat_fee_percents: vat_fee_percents)
  end

  def down
    remove_column :bookings, :vat_fee_percents
  end
end
