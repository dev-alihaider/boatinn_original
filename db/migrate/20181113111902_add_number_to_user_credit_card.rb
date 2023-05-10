class AddNumberToUserCreditCard < ActiveRecord::Migration[5.1]
  def change
    add_column :user_credit_cards, :number, :string
    add_column :user_credit_cards, :brand, :string
  end
end
