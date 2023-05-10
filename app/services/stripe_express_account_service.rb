class StripeExpressAccountService
  attr_reader :user, :callback_url, :refresh_url

  def initialize(user, callback_url: nil, refresh_url: nil)
    @user         = user
    @callback_url = callback_url
    @refresh_url  = refresh_url
  end

  def user_connected?
    user.stripe_account&.payout_ready?
  end

  def edit_account_link
    request = {
      account: express_account_id!,
      refresh_url: refresh_url,
      return_url: callback_url,
      type: 'account_onboarding', # account_update is not working
    }
    with_stripe do
      Stripe::AccountLink.create(request).url
    end
  end

  def process_callback_code(code)
    # ready = [
    #   stripe_account.capabilities.card_payments == 'active',
    #   stripe_account.capabilities.platform_payments == 'active'
    # ]

    user.stripe_account.update(payout_ready: stripe_account!.payouts_enabled)
    @account.payout_ready?
  end

  def stripe_account!
    @account = user.stripe_account || user.build_stripe_account

    if @account.express_account_id.blank?
      with_stripe do
        @stripe_account = Stripe::Account.create(
          type: 'express',
          email: user.email,
          capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true },
          },
          settings: {
            payouts: {
              schedule: {
                interval: :daily
              }
            }
          }
        )
      end
      @account.express_account_id = @stripe_account.id
      @account.save
    end

    @stripe_account ||= with_stripe do
      Stripe::Account.retrieve(user.stripe_account&.express_account_id)
    end
  end

  def express_account_id!
    stripe_account!.id
  end

  def pending?
    !user_connected? && !require_more_info?
  end

  def require_more_info?
    stripe_account!.verification["fields_needed"].present? ||
      stripe_account!.verification["pending_verification"].present?
  end

  def messages

  end

  def with_stripe
    # stripe is configured by default
    # if need use custom config, do it here
    yield
  end

end
