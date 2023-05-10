# frozen_string_literal: true

class ChangeBoatTypeInBoats < ActiveRecord::Migration[5.1] # :nodoc:
  BOAT_TYPES = ['Catamaran', 'Power boat', 'Sailing boat', 'Jet sky', 'Rib',
                'Pontoon'].freeze

  def change
    reversible do |dir|
      dir.up do
        convert_string_to_integer
        change_column :boats, :boat_type, :integer, using: 'boat_type::integer'
      end

      dir.down do
        change_column :boats, :boat_type, :string
        convert_integer_to_string
      end
    end
  end

  def convert_string_to_integer
    Boat.boat_types.each_value do |id|
      Boat.where(boat_type: BOAT_TYPES[id]).update_all(boat_type: id)
    end
  end

  def convert_integer_to_string
    Boat.boat_types.each_value do |id|
      Boat.where(boat_type: id).update_all(boat_type: BOAT_TYPES[id])
    end
  end
end
