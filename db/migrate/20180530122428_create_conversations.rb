# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :conversations, &:timestamps
  end
end
