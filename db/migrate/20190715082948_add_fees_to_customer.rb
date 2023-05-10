class AddFeesToCustomer < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_customers, :cleaning_fee_cents, :integer, default: 0
    add_column :travel_customers, :skipper_fee_cents, :integer, default: 0
  end
end
