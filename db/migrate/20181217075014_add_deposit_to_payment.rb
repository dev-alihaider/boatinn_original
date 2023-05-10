class AddDepositToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :deposit, :boolean, default: false
  end
end
