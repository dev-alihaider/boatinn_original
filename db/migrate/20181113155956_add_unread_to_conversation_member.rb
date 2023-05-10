class AddUnreadToConversationMember < ActiveRecord::Migration[5.1]
  def change
    add_column :conversation_members, :unread, :boolean, default: false
  end
end
