# frozen_string_literal: true

class RenameCalendarsTable < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_table :calendars, :travel_booking_blockings
  end
end
