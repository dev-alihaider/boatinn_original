# frozen_string_literal: true

module Users
  class PaymentsController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!

    def destroy
      res = StripeApi.detach_payment_method(params[:id])
      redirect_back(fallback_location: payment_dashboard_account_index_path)
    end

    private

    def check_count_credit_card
      raise t('users.payments.delete_credit_card') unless current_user.can_remove_card?
    end

    def credit_card_details_params
      params.require(:card_details).permit(
        :address_city,
        :address_country,
        :address_line1,
        :address_line2,
        :address_state,
        :address_zip,
        :exp_month,
        :exp_year,
        :name
      )
    end
  end
end
