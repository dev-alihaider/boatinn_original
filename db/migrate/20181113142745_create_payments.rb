class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.references :booking, index: true
      t.integer :status
      t.integer :sum_cents
      t.integer :earnings_cents
      t.integer :stripe_fee_cents
      t.datetime :captured_at
      t.datetime :transfered_at
      t.datetime :plan_charge_at
      t.string :charge_id
      t.string :balance_txn_id
      t.string :transfer_id
      t.references :payer, references: :user, index: true
      t.string :source_id, index: true
      t.string :currency
      t.integer :try_charge_count, default: 0
      t.timestamps
    end
  end
end
