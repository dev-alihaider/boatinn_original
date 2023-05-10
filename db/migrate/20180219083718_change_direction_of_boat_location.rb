# frozen_string_literal: true

class ChangeDirectionOfBoatLocation < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    reversible do |dir|
      dir.up do
        remove_reference :boats, :location, index: true
        add_reference :locations, :boat, index: true
      end

      dir.down do
        add_reference :boats, :location, index: true
        remove_reference :locations, :boat, index: true
      end
    end
  end
end
