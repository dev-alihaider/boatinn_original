# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController # :nodoc:
    layout -> { request.xhr? ? false : 'user' }

    # POST (/:locale)/users/password
    def create
      self.resource = resource_class
                      .send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        if request.xhr?
          render json: { success: true,
                         message: t('devise.passwords.send_instructions') }
        else
          respond_with({}, location:
            after_sending_reset_password_instructions_path_for(resource_name))
        end
      else
        render json: { success: false, errors:
                 resource.errors.full_messages.join(',') },
               status: :unprocessable_entity
      end
    end

    # PUT (/:locale)/users/password
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?

      resource.errors.delete(:email) if resource.confirmed?

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        if Devise.sign_in_after_reset_password
          flash_message = if resource.active_for_authentication?
                            :updated
                          else
                            :updated_not_active
                          end
          set_flash_message!(:notice, flash_message)
          sign_in(resource_name, resource)
          NotifyService.password_changed(resource)
        else
          set_flash_message!(:notice, :updated_not_active)
        end

        if request.xhr?
          render json: { success: true, partial:
                   render_to_string('devise/passwords/update_successfully',
                                    layout: false) }
        else
          respond_with resource, location:
            after_resetting_password_path_for(resource)
        end
      else
        set_minimum_password_length

        if request.xhr?
          render json: { success: false, errors:
                   resource.errors.full_messages.join(',') },
                 status: :unprocessable_entity
        else
          respond_with resource
        end
      end
    end

    def after_sign_in_path_for(resource)
      root_path
    end

    protected

    def after_sending_reset_password_instructions_path_for(resource_name)
      sent_pass_success_path if is_navigational_format?
    end
  end
end
