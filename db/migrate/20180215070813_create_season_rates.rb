# frozen_string_literal: true

class CreateSeasonRates < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :season_rates do |t|
      t.references  :boat
      t.string :offer_name
      t.date :started_at
      t.date :finished_at
      t.integer :minimum_stay
      t.decimal :per_half_day, precision: 8, scale: 2
      t.decimal :per_day, precision: 8, scale: 2
      t.decimal :per_night, precision: 8, scale: 2
      t.decimal :per_week, precision: 8, scale: 2
      t.timestamps
    end
  end
end
