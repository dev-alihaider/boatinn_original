class RemoveOldData < ActiveRecord::Migration[5.1]
  def change
    remove_column :travel_trips, :seller_seen_last_activity
    remove_column :travel_trips, :seller_seen_last_message

    remove_column :travel_customers, :seen_last_activity
    remove_column :travel_customers, :seen_last_message
  end
end
