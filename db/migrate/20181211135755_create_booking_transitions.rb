class CreateBookingTransitions < ActiveRecord::Migration[5.1]
  def change
    create_table :booking_transitions do |t|
      t.references :message
      t.references :booking
      t.timestamps
    end
  end
end
