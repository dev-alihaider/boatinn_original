# frozen_string_literal: true

class AddAccountNumberToBankAccounts < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :user_bank_accounts, :account_number, :string
  end
end
