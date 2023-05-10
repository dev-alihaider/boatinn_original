# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController # :nodoc:
  layout -> { request.xhr? ? false : 'user' }

  def create
    build_resource(sign_up_params)
    errors = validate_and_persists_resource
    return respond_errors(errors) if errors.present?
    resource.confirmed_at = Time.zone.now if ENV['SKIP_EMAIL_CONFIRMATION']

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        resource.update(auth_via: :email)
        flash[:notice] = t('notices.sign_up_success')
        sign_in(resource)
        if request.xhr?
          render json: { success: true, redirect_to: root_path } and return
        else
          respond_with(resource, location: after_sign_up_path_for(resource)) and return
        end
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        if request.xhr?
          #render partial: 'devise/registrations/after_signup_popup'
          render json: { success: true, message: t('devise.registrations.after_signup_popup.notice') }
        else
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      sentence = I18n.t('errors.messages.not_saved',
                        count: resource.errors.count,
                        resource: resource.class.model_name.human.downcase)
      messages = resource.errors.full_messages.join(', ')

      if request.xhr?
        render json: { success: false, message: "#{sentence} #{messages}", errors: resource.errors.messages }
      else
        flash[:errors] = "#{sentence} #{messages}"
        respond_with resource
      end
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if remotipart_submitted?
      resource_updated = resource.update_without_password(account_update_params)
    else
      resource_updated = update_resource(resource, account_update_params)
      resource_updated = resource.valid? if resource.errors.messages.empty?
    end
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      @change_p = 1
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource) unless remotipart_submitted?
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource unless remotipart_submitted?
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def respond_errors(errors)
    @change_p = 0
    sentence = I18n.t('errors.messages.not_saved',
                      count: errors.count,
                      resource: resource.class.model_name.human.downcase)
    messages = errors.values.join(', ')

    if request.xhr?
      render json: { success: false, message: "#{sentence} #{messages}", errors: errors }
    else
      flash[:errors] = "#{sentence} #{messages}"
      respond_with resource
    end
  end

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  def validate_and_persists_resource
    resource.attributes = {
      first_name: params[:user][:first_name].strip,
      last_name: params[:user][:last_name].strip,
      birthday: DateService.civil(params[:user], :birthday)
    }
    resource.validate
    # validate manual fields
    errors = resource.errors.messages
    errors[:email] = [t('registrations.errors.email')] if resource.email.blank?
    errors[:password] = [t('registrations.errors.password')] if resource.password.blank?
    errors[:first_name] = [t('registrations.errors.first_name')] if resource.first_name.blank?
    errors[:last_name] = [t('registrations.errors.last_name')] if resource.last_name.blank?
    errors[:birthday] = [t('registrations.errors.birthday_not_set')] unless DateService.date_valid?(resource.birthday)

    if resource.birthday
      age_allowed = DateService.age(resource.birthday) >= User::AGE_ALLOWED
      errors[:birthday] = [t('registrations.errors.birthday_old')] unless age_allowed
    end

    resource.save if errors.blank?
    errors
  end
end
