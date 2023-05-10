# frozen_string_literal: true

class RemoveOmniauthNamesFromUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :users, :name_facebook, :string
    remove_column :users, :first_name_facebook, :string
    remove_column :users, :last_name_facebook, :string

    remove_column :users, :name_google_oauth2, :string
    remove_column :users, :first_name_google_oauth2, :string
    remove_column :users, :last_name_google_oauth2, :string
  end
end
