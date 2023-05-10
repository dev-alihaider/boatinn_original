class AddStripeExpressAccountIdToStripeAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_accounts, :express_account_id, :string
    add_column :stripe_accounts, :payout_ready, :boolean, default: false
  end
end
