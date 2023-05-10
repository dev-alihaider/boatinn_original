# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :locations do |t|
      t.string :name
      t.decimal :lat, precision: 11, scale: 8
      t.decimal :lng, precision: 11, scale: 8
      t.timestamps
    end

    #add indexes
    add_index :locations, :lat
    add_index :locations, :lng
    add_index :locations, [:lat, :lng]
  end
end
