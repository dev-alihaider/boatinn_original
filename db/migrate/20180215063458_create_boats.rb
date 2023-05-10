# frozen_string_literal: true

class CreateBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :boats do |t|
      t.string  :boat_type
      t.integer :passengers_count
      # FIXME: Fix typo to `builder_name`.
      t.string :builders_name
      t.string :model_name
      t.integer :length
      t.date :year_of_construction
      t.string :listing_title
      t.text :listing_description
      t.integer :bathrooms_count
      t.integer :cabins_count
      t.integer :beds_count
      t.integer :guest_number
      t.datetime :checkin_time
      t.datetime :chekout_time
      t.string :minimum_rental_time
      t.integer :wizard_progress
      t.references  :location
      t.references :calendar
      t.references :user
      t.decimal :cleaning_fee, precision: 8, scale: 2
      # FIXME: Fix typo to `bedclothes_and_towels`.
      t.decimal :bedclosers_and_towels, precision: 8, scale: 2
      t.decimal :paddle_surf, precision: 8, scale: 2
      # FIXME: Fix typo to `welcome_pack`.
      t.decimal :wellcome_pack, precision: 8, scale: 2
      t.decimal :fuel, precision: 8, scale: 2
      t.decimal :others, precision: 8, scale: 2
      t.timestamps
    end

    #add indexes
    add_index :boats, :passengers_count
    add_index :boats, :length
    add_index :boats, :bathrooms_count
    add_index :boats, :cabins_count
    add_index :boats, :beds_count
    add_index :boats, :guest_number
    add_index :boats, :wizard_progress
  end
end
