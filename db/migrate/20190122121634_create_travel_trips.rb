class CreateTravelTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_trips do |t|
      t.references :boat
      t.references :seller, references: :user
      t.datetime :check_in
      t.datetime :check_out
      t.integer :status
      t.integer :rental
      t.integer :cancellation
      t.integer :number_of_guests
      t.integer :number_of_period
      t.integer :max_guests
      t.integer :min_guests
      t.integer :per_price_cents
      t.integer :seller_fee_cents
      t.integer :client_fee_cents
      t.integer :service_fee_cents
      t.integer :earnings_cents
      t.integer :subtotal_cents
      t.integer :total_cents
      t.integer :vat_fee_percents
      t.string :currency
      t.datetime :transfer_at
      t.text :boat_hash
      t.attachment :image
      t.boolean :seller_seen_last_activity, default: true
      t.timestamps
    end

    add_index :travel_trips, :check_in
    add_index :travel_trips, :check_out
    add_index :travel_trips, :status
    add_index :travel_trips, :rental
    add_index :travel_trips, :transfer_at
    add_index :travel_trips, :seller_seen_last_activity
  end
end
