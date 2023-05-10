class AddRefundsToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_payments, :refunded_cents, :integer
    add_column :travel_payments, :refunded_at, :datetime
  end
end
