module TravelMonetize
  extend ActiveSupport::Concern

  included do
    monetize :per_price_cents,    with_model_currency: :currency
    monetize :subtotal_cents,     with_model_currency: :currency
    monetize :seller_fee_cents,   with_model_currency: :currency
    monetize :client_fee_cents,   with_model_currency: :currency
    monetize :service_fee_cents,  with_model_currency: :currency
    monetize :earnings_cents,     with_model_currency: :currency
    monetize :total_cents,        with_model_currency: :currency
    monetize :cleaning_fee_cents, with_model_currency: :currency
    monetize :skipper_fee_cents,  with_model_currency: :currency

    def reservation_amount
      subtotal + cleaning_fee + skipper_fee
    end
  end

end
