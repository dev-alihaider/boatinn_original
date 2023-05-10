class AddIntentStatusToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_payments, :intent_status, :integer
  end
end
