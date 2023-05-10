# frozen_string_literal: true

module Api
  class CurrenciesController < Api::GenericController # :nodoc:
    # PATCH /api/set_current_currency.json
    def set_current_currency
      if user_signed_in?
        current_user.update(currency: params[:currency])
      else
        session[:current_currency] = params[:currency]
      end
    end
  end
end
