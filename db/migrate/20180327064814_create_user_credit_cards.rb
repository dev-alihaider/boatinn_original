# frozen_string_literal: true

class CreateUserCreditCards < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :user_credit_cards do |t|
      t.references :user
      t.string :credit_card_token
      t.boolean :credit_card_default, default: false
      t.timestamps
    end
  end
end
