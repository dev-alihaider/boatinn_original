class AddCancelerToTripCancellation < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_trip_cancellations, :canceler_id, :integer
    add_index :travel_trip_cancellations, :canceler_id
  end
end
