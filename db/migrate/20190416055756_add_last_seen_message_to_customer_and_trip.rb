class AddLastSeenMessageToCustomerAndTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_trips, :seller_seen_last_message, :boolean, default: false
    add_column :travel_customers, :seen_last_message,    :boolean, default: false

    add_index :travel_trips, :seller_seen_last_message
    add_index :travel_customers, :seen_last_message
  end
end
