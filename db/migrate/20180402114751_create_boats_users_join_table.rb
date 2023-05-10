# frozen_string_literal: true

class CreateBoatsUsersJoinTable < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_join_table :boats, :users do |t|
      t.index :boat_id
      t.index :user_id
      t.timestamps
    end
    add_index :boats_users, %i[boat_id user_id], unique: true
  end
end
