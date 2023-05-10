class CreateTravelCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_customers do |t|
      t.references :trip
      t.references :client, references: :user
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
      t.datetime :last_activity
      t.boolean :seen_last_activity, default: true
      t.datetime :left_at
      t.timestamps
    end

    add_index :travel_customers, :last_activity
    add_index :travel_customers, :seen_last_activity
    add_index :travel_customers, :left_at
  end
end
