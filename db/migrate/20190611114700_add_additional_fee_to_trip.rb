class AddAdditionalFeeToTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_trips, :cleaning_fee_cents, :integer, default: 0
    add_column :travel_trips, :skipper_fee_cents, :integer, default: 0
    add_column :travel_trips, :skipper_included, :boolean
  end
end
