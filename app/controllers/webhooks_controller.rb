class WebhooksController < ActionController::Base
  def stripe_webhook
    params.permit!

    case params['type']
    when 'account.updated'
      account = params['data']['object']
      account_id = account['id']
      user = StripeAccount.find_by(express_account_id: account_id)
      if user.present?
        service = StripeExpressAccountService.new(user)
        service.process_callback_code(nil)
      else
        warn("Unhandled express account id: #{account_id}")
      end
    else
      warn("Unhandled event type: #{params[:type]}")
    end

    head 200
  end
end
