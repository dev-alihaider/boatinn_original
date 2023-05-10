class CreateTravelPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_payments do |t|
      t.references :booking
      t.integer :status
      t.integer :type_of
      t.string :charge_id
      t.string :balance_txn_id
      t.string :transfer_id
      t.integer :stripe_fee_cents
      t.integer :per_price_cents
      t.integer :seller_fee_cents
      t.integer :client_fee_cents
      t.integer :service_fee_cents
      t.integer :earnings_cents
      t.integer :subtotal_cents
      t.integer :total_cents
      t.integer :penalty_from_seller_cents
      t.string :currency
      t.string :source
      t.integer :try_charge_count, default: 0
      t.datetime :captured_at
      t.datetime :transferred_at
      t.datetime :plan_charge_at
      t.datetime :last_charge_fail_at
      t.boolean :urgent, default: false
      t.timestamps
    end

    add_index :travel_payments, :status
    add_index :travel_payments, :type_of
    add_index :travel_payments, :captured_at
    add_index :travel_payments, :transferred_at
    add_index :travel_payments, :plan_charge_at
    add_index :travel_payments, :urgent
  end
end
