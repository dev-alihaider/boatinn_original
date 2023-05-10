# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController # :nodoc:
  respond_to :html, :json

  protect_from_forgery prepend: true, with: :exception

  layout -> { request.xhr? ? false : 'user' }

  # @see ApplicationController#referer_or_root_path
  def new
    if request.referer.present? && request.referer.include?(request.base_url)
      path = extract_path_from_location(request.referer)
      session['user_sign_in_referer'] = path if path
    end

    super
  end

  def create
    if request.xhr?
      begin
        previous_url = request.referer
        user = User.find_by(email: params['user']['email'])
        if user.present?
          return render_account_closed_error if user.closed?

          if user.confirmed_at
            return render_blocked_error if user.blocked?

            resource = warden.authenticate!(scope: resource_name, recall: 'users/sessions#failure')
            user.update(auth_via: :email)
            sign_in_and_redirect_back(resource_name, previous_url, resource)
          else
            render json: { success: false, errors: t('devise.failure.unconfirmed_at') }, status: :unauthorized
          end
        else
          render_json_failure
        end
      rescue StandardError
        render_json_failure
      end
    else
      super
    end
  end

  def failure
    render_json_failure
  end

  private

  def sign_in_and_redirect_back(resource_or_scope, previous_url, resource = nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    flash[:notice] = t('devise.sessions.signed_in')
    render json: { success: true, location: previous_url }
  end

  def render_json_failure
    render json: { success: false,
                   errors: t('devise.failure.invalid',
                             authentication_keys:
                               Devise.authentication_keys.join(', ')) },
           status: :unauthorized
  end

  def render_blocked_error
    flash[:failure] = t('devise.failure.blocked')
    render json: { success: false, errors: t('devise.failure.blocked') },
           status: :unauthorized
  end

  def render_account_closed_error
    flash[:failure] = t('devise.failure.closed') unless request.xhr?
    render json: { success: false, errors: t('devise.failure.closed') },
           status: :unauthorized
  end
end
