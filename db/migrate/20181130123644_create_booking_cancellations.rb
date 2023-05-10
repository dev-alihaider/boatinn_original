class CreateBookingCancellations < ActiveRecord::Migration[5.1]
  def change
    create_table :booking_cancellations do |t|
      t.references :booking
      t.integer :subject
      t.text :reason
      t.integer :amount_cents, default: 0
      t.text :currency
      t.boolean :client
      t.timestamps
    end
  end
end
