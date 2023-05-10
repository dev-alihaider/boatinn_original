# frozen_string_literal: true

class AddClosedToUser < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :closed, :boolean, index: true, default: false
  end
end
