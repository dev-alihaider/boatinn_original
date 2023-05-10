# frozen_string_literal: true

class AddSharedSleepinColumnsToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :shared, :boolean, null: false, default: false
    add_column :boats, :sleepin, :boolean, null: false, default: false
    add_column :boats, :shared_price, :decimal, precision: 8, scale: 2
  end
end
