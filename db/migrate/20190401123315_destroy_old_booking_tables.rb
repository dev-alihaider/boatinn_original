class DestroyOldBookingTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :booking_cancellations
    drop_table :booking_transitions
    drop_table :conversations
    drop_table :conversation_members
    drop_table :invoices
    drop_table :messages
    drop_table :payments
  end
end
