module Api
  class StripeController < Api::GenericController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!

    # GET user payment methods list
    def payment_methods
      result = StripeApi.user_payment_methods(current_user)
      render json: result
    end

    # POST setup new payment intent
    def setup_intent
      intent = Stripe::SetupIntent.create(
        customer: StripeApi.user_customer_id!(current_user),
        payment_method_types: ['card']
     )

      render json: {
        client_secret: intent.client_secret
      }
    end
  end
end
