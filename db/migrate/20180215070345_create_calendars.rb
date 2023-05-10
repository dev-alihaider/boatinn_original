# frozen_string_literal: true

class CreateCalendars < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :calendars do |t|
      t.references  :boat
      t.date :started_at
      t.date :finished_at
      t.timestamps
    end
  end
end
