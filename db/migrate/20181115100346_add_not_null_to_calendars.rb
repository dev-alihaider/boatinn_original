# frozen_string_literal: true

class AddNotNullToCalendars < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    change_column_null :calendars, :started_at, false
    change_column_null :calendars, :finished_at, false
  end
end
