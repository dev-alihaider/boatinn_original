class AddViewedAtToTripAndCustomer < ActiveRecord::Migration[5.1]
  def change
    past_time = Time.new(1970, 1, 1, 0, 0, 0, 0)
    add_column :travel_trips, :seller_seen_at, :datetime, default: past_time
    add_column :travel_customers, :seen_at, :datetime, default: past_time

    add_index :travel_trips, :seller_seen_at
    add_index :travel_customers, :seen_at
  end
end
