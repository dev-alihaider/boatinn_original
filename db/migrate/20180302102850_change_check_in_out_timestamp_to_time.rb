# frozen_string_literal: true

class ChangeCheckInOutTimestampToTime < ActiveRecord::Migration[5.1] # :nodoc:
  def up
    remove_column :boats, :checkin_time
    remove_column :boats, :chekout_time

    add_column :boats, :check_in_time, :time
    add_column :boats, :check_out_time, :time
  end

  def down
    remove_column :boats, :check_in_time
    remove_column :boats, :check_out_time

    add_column :boats, :checkin_time, :timestamp
    add_column :boats, :chekout_time, :timestamp
  end
end
