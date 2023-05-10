class AddTravelCanceledToConversation < ActiveRecord::Migration[5.1]
  def up
    add_column :conversations, :travel_canceled, :boolean, default: false
    add_index :conversations, :travel_canceled

    # Conversation.find_each do |conversation|
    #   canceled = conversation.bookings.where(status: %w[accepted completed]).blank?
    #   conversation.update_column(:travel_canceled, canceled)
    # end
  end

  def down
    remove_index :conversations, :travel_canceled
    remove_column :conversations, :travel_canceled
  end
end
