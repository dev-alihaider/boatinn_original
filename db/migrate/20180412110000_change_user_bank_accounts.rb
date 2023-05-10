# frozen_string_literal: true

class ChangeUserBankAccounts < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :user_bank_accounts, :account_holder_name
    remove_column :user_bank_accounts, :bank_name
    remove_column :user_bank_accounts, :swift
    remove_column :user_bank_accounts, :iban

    add_reference :user_bank_accounts, :stripe_account
    add_column :user_bank_accounts, :bank_account_id, :string
  end
end
