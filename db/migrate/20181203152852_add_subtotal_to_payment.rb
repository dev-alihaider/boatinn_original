class AddSubtotalToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :subtotal_cents, :integer, default: 0
    add_column :payments, :client_fee_cents, :integer, default: 0
  end
end
