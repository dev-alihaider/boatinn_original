# frozen_string_literal: true

class MoveCaptainFromUsersToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :users, :captain, :boolean, null: false, default: false
    add_column :boats, :captain, :integer, null: false, default: 0
  end
end
