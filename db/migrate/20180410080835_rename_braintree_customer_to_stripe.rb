# frozen_string_literal: true

class RenameBraintreeCustomerToStripe < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_column :users, :braintree_customer_id, :stripe_customer_id
  end
end
