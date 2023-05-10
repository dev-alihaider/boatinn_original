# frozen_string_literal: true

class ApplicationController < ActionController::Base # :nodoc:
  protect_from_forgery with: :exception
  before_action :store_location_for_user

  # Meta description and title
  @metatitle
  @metadescription
  @metaswitch = 1

  def set_layout
    self.class.to_s.include?('Admin::') ? 'admin' : 'user'
  end

  def after_sign_in_path_for(_resource_or_scope)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_url
  end

  def after_sign_out_path_for(_resource_or_scope)
    referer_or_root_path
  end

  private

  # OmniAuth sign in: prewizards_path -> redirect to listing creation.
  # If not OmniAuth and referer present then check that referer != current url
  # to avoid infinite redirect loop.
  # @see Users::SessionsController#new
  def referer_or_root_path
    sign_in_page_referer = session.delete('user_sign_in_referer')
    omniauth_origin = request.env['omniauth.origin'].presence
    stored_location_for_user = stored_location_for(:user)
    referer = omniauth_origin || request.referer

    if valid_referer?(sign_in_page_referer)
      sign_in_page_referer
    elsif omniauth_origin&.include?(prewizards_path)
      new_wizard_path(locale: helpers.current_locale)
    elsif stored_location_for_user.present?
      stored_location_for_user
    elsif valid_referer?(referer) && referer != request.url
      referer
    else
      root_path
    end
  end

  def valid_referer?(referer_url)
    referer_url.present? && referer_url.include?(request.base_url)
  end

  # def authenticate_user!
  #   return super if user_signed_in?
  #
  #   redirect_to root_path, notice: t('devise.failure.unauthenticated')
  # end

  def store_location_for_user
    return if %w[registrations sessions].include?(controller_name)
    return if !request.get? || request.xhr? || request.format.to_sym != :html
    return if request.env['omniauth.origin'].presence
    store_location_for(User, request.path)
  end
end
