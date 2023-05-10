# frozen_string_literal: true

class AddSharedSleepinTimesExtraColumnsToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :shared_check_in_time, :time
    add_column :boats, :shared_check_out_time, :time

    add_column :boats, :sleepin_check_in_time, :time
    add_column :boats, :sleepin_check_out_time, :time
    add_column :boats, :sleepin_min_rental_time, :time
    add_column :boats, :sleepin_extra_guests, :integer
    add_column :boats, :sleepin_extra_price, :decimal, precision: 8, scale: 2

    add_index :boats, :sleepin_extra_guests
    add_index :boats, :sleepin_extra_price
  end
end
