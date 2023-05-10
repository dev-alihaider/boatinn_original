# frozen_string_literal: true

class ChangeMinimumStayInBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :boats, :minimum_stay, :integer
    change_column :boats, :minimum_rental_time, 'integer USING CAST(minimum_rental_time AS integer)'
  end
end
