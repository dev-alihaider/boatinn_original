class AddVirifyToStripeAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_accounts, :account_verified, :boolean, default: false
  end
end
