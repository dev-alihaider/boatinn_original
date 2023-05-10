# frozen_string_literal: true

class AddClassicToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :classic, :boolean, null: false, default: true
  end
end
