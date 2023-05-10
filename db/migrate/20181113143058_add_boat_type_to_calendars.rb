# frozen_string_literal: true

class AddBoatTypeToCalendars < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :calendars, :rental_type, :integer, null: false, default: 0
  end
end
