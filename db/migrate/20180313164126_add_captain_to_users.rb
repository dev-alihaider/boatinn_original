# frozen_string_literal: true

class AddCaptainToUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :captain, :boolean, null: false, default: false
  end
end
