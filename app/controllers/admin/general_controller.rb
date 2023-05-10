# frozen_string_literal: true

module Admin
  class GeneralController < ApplicationController # :nodoc:
    include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

    before_action :authenticate_user!, :check_user

    layout :set_layout

    # def default_url_options
    #   { locale:I18n.locale }
    # end

    protected

    def check_user
      return if current_user.admin?

      flash[:error] = t('admin.general.check_user.not_admin_message')
      redirect_to(root_path) && return
    end
  end
end