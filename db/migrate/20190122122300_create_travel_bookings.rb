class CreateTravelBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_bookings do |t|
      t.references :trip
      t.references :client, references: :user
      t.integer :status
      t.integer :payment_process
      t.integer :number_of_guests
      t.integer :number_of_period
      t.integer :per_price_cents
      t.integer :seller_fee_cents
      t.integer :client_fee_cents
      t.integer :service_fee_cents
      t.integer :earnings_cents
      t.integer :subtotal_cents
      t.integer :total_cents
      t.string :currency
      t.string :reservation_code
      t.timestamps
    end

    add_index :travel_bookings, :status
    add_index :travel_bookings, :reservation_code, unique: true
  end
end
