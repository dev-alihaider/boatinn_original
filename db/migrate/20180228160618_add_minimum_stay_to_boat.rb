# frozen_string_literal: true

class AddMinimumStayToBoat < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :boats, :minimum_stay, :integer
  end
end
