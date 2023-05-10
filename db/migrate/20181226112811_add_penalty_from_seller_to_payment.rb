class AddPenaltyFromSellerToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :penalty_from_seller_cents, :integer, default: 0
  end
end
