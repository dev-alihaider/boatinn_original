module Users
  class StripeAccountsController < GeneralUsersController
    before_action :authenticate_user!

    # refresh status
    before_action only: %i[show] do
      if current_user.stripe_account.present?
        unless current_user.payoutable?
          if current_user.stripe_account.express_account_id.present?
            service.process_callback_code(nil)
          end
        end
      end
    end

    def show
      render locals: {
        service: service,
        onboarding_path: onboarding_dashboard_stripe_account_path
      }
    end

    def onboarding
      with_exception do
        redirect_to(service.edit_account_link)
      end
    end

    def refresh
      service.process_callback_code(params[:code])
      onboarding
    end

    def callback
      if service.process_callback_code(params[:code])
        flash[:notice] = t('stripe_account.created_success')
      else
        flash[:error] = t('stripe_account.created_failure')
      end
      redirect_to action: :show
    end


    private

    def service
      @service ||= StripeExpressAccountService.new(@current_user, {
        callback_url: callback_dashboard_stripe_account_url,
        refresh_url: refresh_dashboard_stripe_account_url
      })
    end

    def with_exception
      begin
        yield
      # rescue StandardError => e
      #   flash[:error] = e.message
      #   redirect_back(fallback_location: dashboard_stripe_account_path)
      end
    end
  end
end
