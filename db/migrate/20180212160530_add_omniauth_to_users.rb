# frozen_string_literal: true

class AddOmniauthToUsers < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    # NOTE: To store the method by which the user is authorized.
    add_column :users, :auth_via, :string

    add_facebook_columns
    add_google_columns

    add_indexes
  end

  # == Facebook ==
  def add_facebook_columns
    # General OAuth 2.0 required columns.
    # NOTE: request.env['omniauth.auth']['provider'] => `facebook` -> name received from the Facebook provider.
    
    add_column :users, :uid_facebook, :string

    # TODO: Not required columns, but may be useful for further sign out function after access token expires.
    # add_column :users, :oauth_facebook_token, :string
    # add_column :users, :oauth_facebook_expires_at, :datetime

    # User data columns received from provider.
    add_column :users, :name_facebook, :string
    add_column :users, :first_name_facebook, :string
    add_column :users, :last_name_facebook, :string
    # TODO: May be useful to store user locale.
    # add_column :users, :locale_facebook, :string
    add_column :users, :profile_url_facebook, :string
    add_column :users, :image_url_facebook, :string
  end

  # == Google ==
  def add_google_columns
    # NOTE: request.env['omniauth.auth']['provider'] => `google_oauth2` -> name received from the Google provider.
    add_column :users, :uid_google_oauth2, :string

    # add_column :users, :oauth_google_oauth2_token, :string
    # add_column :users, :oauth_google_oauth2_expires_at, :datetime

    add_column :users, :name_google_oauth2, :string
    add_column :users, :first_name_google_oauth2, :string
    add_column :users, :last_name_google_oauth2, :string
    # add_column :users, :locale_google_oauth2, :string
    add_column :users, :profile_url_google_oauth2, :string
    add_column :users, :image_url_google_oauth2, :string
  end

  def add_indexes
    add_index :users, :auth_via
    add_index :users, :uid_facebook
    add_index :users, :uid_google_oauth2
  end
end
