# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController # :nodoc:
    layout 'user'

    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    def show
      super do
        EmailConfirmedJob.perform_later(resource.id) if resource.errors.empty?
      end

      return if resource.errors.blank?

      flash[:error] = resource.errors.full_messages.join(',')
    end

    protected

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    def after_confirmation_path_for(_resource_name, resource)
      sign_in(resource)
      root_path
    end
  end
end
