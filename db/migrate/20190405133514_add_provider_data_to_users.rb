# frozen_string_literal: true

class AddProviderDataToUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :users, :facebook_data, :jsonb, null: false, default: {}
    add_column :users, :google_oauth2_data, :jsonb, null: false, default: {}
  end
end
