# frozen_string_literal: true

class CreateUserBankAccounts < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :user_bank_accounts do |t|
      t.string :account_holder_name
      t.string :bank_name
      t.string :swift
      t.string :iban

      t.timestamps
    end
  end
end
