# frozen_string_literal: true

class AddPhoneFieldsToUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :phone_number, :string
    add_column :users, :phone_verification_code, :string
    add_column :users, :phone_verification_code_sent_at, :datetime
    add_column :users, :phone_verified, :boolean, null: false, default: false
  end
end
