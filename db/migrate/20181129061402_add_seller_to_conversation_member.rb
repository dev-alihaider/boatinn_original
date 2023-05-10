class AddSellerToConversationMember < ActiveRecord::Migration[5.1]
  def up
    add_column :conversation_members, :seller, :boolean, default: false

    Booking.find_each do |booking|
      booking.members.find_by(user_id: booking.seller_id)&.update(seller: true)
    end

  end

  def down
    remove_column :conversation_members, :seller
  end
end
