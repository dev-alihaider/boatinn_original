class AddChargeCounterToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :charge_fail_counter, :integer, default: 0
    add_column :payments, :last_charge_fail_at, :datetime
  end
end
