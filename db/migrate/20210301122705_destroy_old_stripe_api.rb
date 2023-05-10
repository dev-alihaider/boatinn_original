class DestroyOldStripeApi < ActiveRecord::Migration[5.1]
  def change
    drop_table :user_bank_accounts
    drop_table :user_credit_cards
    remove_column :travel_payments, :status
  end
end
