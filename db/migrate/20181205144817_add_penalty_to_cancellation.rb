class AddPenaltyToCancellation < ActiveRecord::Migration[5.1]
  def change
    add_column :booking_cancellations, :penalty_cents, :integer, default: 0
    add_column :booking_cancellations, :penalty_currency, :string
  end
end
