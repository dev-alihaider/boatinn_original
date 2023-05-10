# frozen_string_literal: true

class CreateConversationMembers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :conversation_members do |t|
      t.references :conversation
      t.references :user

      t.timestamps
    end

    add_index :conversation_members, %i[conversation_id user_id], unique: true
  end
end
