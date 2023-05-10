# frozen_string_literal: true

class RemoveFacebookGoogleProfileUrlFromUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :users, :profile_url_facebook, :string
    remove_column :users, :profile_url_google_oauth2, :string
  end
end
