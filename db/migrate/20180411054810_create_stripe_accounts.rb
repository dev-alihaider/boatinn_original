# frozen_string_literal: true

class CreateStripeAccounts < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :stripe_accounts do |t|
      t.references :user
      t.string :stripe_user_id
      t.string :stripe_account_type
      t.string :publishable_key
      t.string :secret_key
      t.string :stripe_customer_id
      t.timestamps
    end
  end
end
