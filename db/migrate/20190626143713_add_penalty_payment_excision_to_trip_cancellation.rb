class AddPenaltyPaymentExcisionToTripCancellation < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_trip_cancellations, :payment_penalty_excision_id, :integer
  end
end
