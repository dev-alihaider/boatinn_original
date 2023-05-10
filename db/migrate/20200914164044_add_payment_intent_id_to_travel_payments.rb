class AddPaymentIntentIdToTravelPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_payments, :payment_intent_id, :string
  end
end
