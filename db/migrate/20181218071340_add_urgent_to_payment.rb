class AddUrgentToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :urgent, :boolean, default: false
  end
end
