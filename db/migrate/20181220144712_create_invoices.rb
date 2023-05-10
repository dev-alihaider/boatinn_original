class CreateInvoices < ActiveRecord::Migration[5.1]
  def up
    create_table :invoices do |t|
      t.references :booking
      t.string :client_number
      t.string :seller_number
    end

    # Booking.find_each do |booking|
    #   Invoice.generate_new_numbers(booking.id)
    # end
  end

  def down
    drop_table :invoices
  end
end
