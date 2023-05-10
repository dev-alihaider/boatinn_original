# frozen_string_literal: true

class ChangeSleepinMinRentalTimeInBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def up
    remove_column :boats, :sleepin_min_rental_time
    add_column :boats, :sleepin_min_rental_time, :integer
  end

  def down
    remove_column :boats, :sleepin_min_rental_time
    add_column :boats, :sleepin_min_rental_time, :time
  end
end

