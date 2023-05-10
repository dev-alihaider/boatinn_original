# frozen_string_literal: true

module Api
  # REST JSON API for Facebook/Google Omniauth: user can connect/disconnect.
  class OmniauthConnectionsController < Api::GenericController
    before_action :authenticate_user!

    # PATCH (/:locale)/dashboard/profile/connect_facebook
    # def connect_facebook
    #   redirect_to user_facebook_omniauth_authorize_path(locale: nil)
    # end

    # PATCH (/:locale)/dashboard/profile/connect_google
    # def connect_google
    #   redirect_to user_google_oauth2_omniauth_authorize_path(locale: nil)
    # end

    # PATCH (/:locale)/dashboard/profile/disconnect_facebook
    def disconnect_facebook
      delete_provider_data('facebook')
    end

    # PATCH (/:locale)/dashboard/profile/disconnect_google
    def disconnect_google
      delete_provider_data('google_oauth2')
    end

    private

    def delete_provider_data(provider)
      current_user.update("uid_#{provider}": '',
                          "image_url_#{provider}": '',
                          "#{provider}_data": {})
    end
  end
end
