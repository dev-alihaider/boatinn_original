# frozen_string_literal: true

class AddSuplementaryFieldsToBoat < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :per_half_day, :decimal, precision: 8, scale: 2
    add_column :boats, :per_day, :decimal, precision: 8, scale: 2
    add_column :boats, :per_night, :decimal, precision: 8, scale: 2
    add_column :boats, :per_week, :decimal, precision: 8, scale: 2
  end
end
