# frozen_string_literal: true

class GeneralUsersController < ApplicationController # :nodoc:
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  layout :set_layout

  before_action :set_locale

  # First set current locale from `params[:locale]`,
  # then from database for signed in user `current_user.language`
  # then if signed out user from `session[:locale]`
  # last fallback to default locale and save to storage.
  def set_locale
    if params[:locale].blank?
      I18n.locale = extract_locale_from_accept_language_header
    else
       if request.get? && !I18n.locale_available?(params[:locale])
         localized_path = "/#{helpers.current_locale}#{request.original_fullpath}"
         return redirect_to(localized_path)
       end
    end

    I18n.locale = params[:locale] || helpers.current_locale
    
    # Check locale en es
    if I18n.locale != :en && I18n.locale != :es
        I18n.locale =  I18n.default_locale
    end    

    if user_signed_in?
      current_user.update(language: I18n.locale)
    else
      session[:locale] = I18n.locale
    end
  end

  def default_url_options
    { locale: helpers.current_locale }
  end

  private

  def render_not_found
    render 'users/listings/not_found', status: :not_found
  end

  # extract the language from the clients browser
  def extract_locale_from_accept_language_header
    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first).try(:to_sym)
    if I18n.available_locales.include? browser_locale
      browser_locale
    else
      I18n.default_locale
    end
  end
end