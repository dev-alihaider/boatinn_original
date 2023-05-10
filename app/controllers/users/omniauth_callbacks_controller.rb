# frozen_string_literal: true

module Users
  ##
  # This controller class handle callbacks from different Omniauth providers.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def facebook
      callback_from :facebook
    end

    def google_oauth2
      callback_from :google
    end

    def failure
      redirect_to root_path
    end

    private

    def callback_from(provider)
      provider = provider.to_s
      provider_data = request.env['omniauth.auth']
      email = provider_data.info.email

      # NOTE: If provider email blank then redirect to root with error.
      # TODO: Alternative scenario: generate dummy email from Omniauth data and create user.
      #   "#{provider_data.uid}-#{provider_data.provider}@#{provider_data.provider}.com"
      if email.blank?
        set_flash_message(:alert, :failure, kind: provider.capitalize,
                                            reason: 'email ' + t('errors.messages.blank')) # blank | empty | required
        return redirect_to(root_path)
      end

      user = current_user if user_signed_in?
      user ||= User.find_with_omniauth(provider_data)
      user ||= User.find_by(email: email)

      if user
        # NOTE: User created account via email, not confirmed and tried to auth
        # via OmniAuth => skip email confirmation.
        user.skip_confirmation! unless user.confirmed?
        user.update_with_omniauth(provider_data)
      else
        user = User.create_with_omniauth(provider_data)
        # Set locale if new user created.
        provider_locale = provider_data
                          &.extra&.raw_info&.locale&.split('_')&.first
        if provider_locale.present? &&
           Boatinn::AVAILABLE_LOCALES_SHORT_FORMAT.include?(provider_locale)
          user.update(language: provider_locale)
        end
      end

      if user.persisted?
        sign_in_and_redirect(user) # This will throw if `user` is not activated
        set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = request.env['omniauth.auth'].except('extra')
        redirect_to new_user_registration_url
      end
    end
  end
end
