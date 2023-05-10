class AddFeesToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_payments, :cleaning_fee_cents, :integer, default: 0
    add_column :travel_payments, :skipper_fee_cents, :integer, default: 0
  end
end
