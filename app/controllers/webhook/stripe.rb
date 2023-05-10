module Webhook
  class StripeController < BaseController

    before_action :ensure_event

    def account
      return head(400) unless @type.start_with?("account.")

      # service = StripeVerification.new(nil)
      # service.resolve_session(stripe_session_id:  @object['id'])
      head(200)
    end


    def ensure_event
      begin
        data = request.raw_post
        signature = request.env['HTTP_STRIPE_SIGNATURE']
        secret = ENV['STRIPE_SIGN_IN_KEY']
        @event = Stripe::Webhook.construct_event(data, signature, secret)
        @object = @event['data']['object']
        @type = @event['type'].to_s
      rescue Stripe::SignatureVerificationError => e
        return head(400)
      rescue StandardError => e
        return head(400)
      end
    end
  end
end
