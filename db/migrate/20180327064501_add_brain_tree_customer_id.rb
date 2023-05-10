# frozen_string_literal: true

class AddBrainTreeCustomerId < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :braintree_customer_id, :string
  end
end
