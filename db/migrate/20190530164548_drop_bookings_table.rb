# frozen_string_literal: true

class DropBookingsTable < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    drop_table :bookings do |t|
      t.references :boat, index: true
      t.references :seller, references: :user, index: true
      t.references :client, references: :user, index: true
      t.references :conversation, references: :user, index: true
      t.integer :status
      t.integer :tx_process
      t.integer :cancellation
      t.integer :rental_type
      t.integer :per_quantity
      t.integer :passenger_quantity
      t.string :currency
      t.integer :unit_price_cents
      t.integer :subtotal_cents
      t.integer :seller_fee_cents
      t.integer :client_fee_cents
      t.integer :service_fee_cents
      t.integer :earnings_cents
      t.integer :total_cents
      t.datetime :start_at
      t.datetime :end_at
      t.string :reservation_code, index: { unique: true }
      t.string :boat_name
      t.datetime :transfer_at
      t.decimal :vat_fee_percents, precision: 5, scale: 2, default: 0.0
      t.string :boat_address

      t.timestamps
    end
  end
end
