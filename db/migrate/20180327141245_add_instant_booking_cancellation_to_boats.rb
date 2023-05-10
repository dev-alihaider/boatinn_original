# frozen_string_literal: true

# :nodoc:
class AddInstantBookingCancellationToBoats < ActiveRecord::Migration[5.1]
  def change
    add_column :boats, :instant_booking, :boolean, null: false, default: false
    add_column :boats, :cancellation, :integer, null: false, default: 0
  end
end
