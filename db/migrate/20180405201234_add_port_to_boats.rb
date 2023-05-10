# frozen_string_literal: true

class AddPortToBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :port, :string
  end
end
