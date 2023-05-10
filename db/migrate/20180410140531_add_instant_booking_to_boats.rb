# frozen_string_literal: true

class AddInstantBookingToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_column :boats, :instant_booking, :instant_booking_classic
    add_column :boats, :instant_booking_sleepin, :boolean,
               null: false, default: false
    add_column :boats, :instant_booking_shared, :boolean,
               null: false, default: false
  end
end
