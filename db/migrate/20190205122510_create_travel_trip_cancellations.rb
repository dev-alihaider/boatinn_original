class CreateTravelTripCancellations < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_trip_cancellations do |t|
      t.references :trip
      t.integer :subject
      t.text :reason
      t.boolean :seller
      t.integer :refunded_cents
      t.integer :penalty_cents
      t.string :currency
      t.timestamps
    end
  end
end
