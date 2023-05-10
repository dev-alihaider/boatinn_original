class AddDisabledToConversationMemeber < ActiveRecord::Migration[5.1]
  def change
    add_column :conversation_members, :left_at, :datetime
  end
end
