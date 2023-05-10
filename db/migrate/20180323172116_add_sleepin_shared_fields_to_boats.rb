# frozen_string_literal: true

class AddSleepinSharedFieldsToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :sleepin_description, :string
    add_column :boats, :sleepin_max_passengers, :integer
    add_column :boats, :sleepin_per_night, :decimal, precision: 8, scale: 2

    add_column :boats, :shared_description, :string
    add_column :boats, :shared_min_passengers, :integer
    add_column :boats, :shared_max_passengers, :integer
    add_column :boats, :shared_per_person, :decimal, precision: 8, scale: 2

    add_indexes
  end

  def add_indexes
    add_index :boats, :sleepin_max_passengers
    add_index :boats, :sleepin_per_night
    add_index :boats, :shared_min_passengers
    add_index :boats, :shared_max_passengers
    add_index :boats, :shared_per_person
  end
end
