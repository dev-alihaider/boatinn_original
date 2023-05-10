# frozen_string_literal: true

class AddBlockedAtToUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :blocked_at, :datetime
  end
end
