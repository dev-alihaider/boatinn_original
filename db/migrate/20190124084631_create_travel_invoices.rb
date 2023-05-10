class CreateTravelInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_invoices do |t|
      t.references :booking
      t.string :client_number
      t.string :seller_number
      t.timestamps
    end

    add_index :travel_invoices, :client_number, unique: true
    add_index :travel_invoices, :seller_number, unique: true
  end
end
