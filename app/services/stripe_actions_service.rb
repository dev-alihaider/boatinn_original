# frozen_string_literal: true

# this service is deprecated
# use StripeExpressAccountService instead
class StripeActionsService # :nodoc:

  def bt_customer_id(user)
    user.stripe_customer_id || create_user(user)
  end

  def account_id(user, country, ip, type)
    user.stripe_account || create_stripe_account(user, country, ip, type)
  end

  def create_bank_account(user, account, params)
    stripe_account = Stripe::Account.retrieve(account.stripe_user_id)
    ba = stripe_account.external_accounts.create(external_account: params[:bank_card_token])
    user_payout = UserPayout.new(user: user)
    bank_account = UserBankAccount.new
    bank_account.stripe_account = account
    bank_account.account_number = params[:account_number]
    bank_account.bank_account_id = ba['id']
    bank_account.user_payouts << user_payout
    bank_account.save!
  end

  def create_stripe_account(user, country, ip, type)
    acc = Stripe::Account.create(
      type: 'custom',
      country: country,
      email: user.email,
      legal_entity: { type: type },
      tos_acceptance: { date: Time.now.to_i, ip: ip }
    )
    StripeAccount.create!(user: user, stripe_account_type: :custom,
                          stripe_user_id: acc['id'],
                          publishable_key: acc['keys']['publishable'],
                          secret_key: acc['keys']['secret'])
  end

  def create_user(user)
    customer = Stripe::Customer.create(
      description: "Customer for #{user.email}",
      email: user.email,
      name: user.display_name,
      phone: user.phone_number
    )
    @user_id = customer['id']
    user.update_attributes!(stripe_customer_id: @user_id)
    @user_id
  end

  def add_credit_card(customer_id, card_token)
    customer = stripe_customer(customer_id)
    result = customer.sources.create(source: card_token)
    result['id']
  end

  # fields is hash with keys
  # [address_city address_country address_line1 address_line2 address_state]
  # [address_zip exp_month exp_year metadata name]
  def update_credit_card(credit_card, fields)
    Stripe::Customer.update_source(
      credit_card.user.stripe_customer_id,
      credit_card.credit_card_token,
      fields
    )
  end

  def find_credit_card(customer_id, card_token)
    stripe_customer(customer_id).sources.retrieve(card_token)
  rescue StandardError
    nil
  end

  def delete_cc(customer_id, card_token)
    result = stripe_customer(customer_id).sources.retrieve(card_token).delete
    result['deleted']
  end

  def connect_to(params)
    connector = StripeOauth.new(current_user)
    if params[:code]
      connector.verify!(params[:code])
    elsif params[:error]
      flash[:error] = 'Authorization request denied.'
    end
  end

  def oauth
    connector = StripeOauth.new(current_user)
    url, error = connector.oauth_url(redirect_url)
    if url.nil?
      flash[:error] = error
      redirect_to payout_dashboard_account_index_path
    else
      redirect_to url
    end
  end

  def booking(amount, source:, currency:, capture:, transfer_group: nil)
    payment = { amount: amount, currency: currency, customer: source, capture: capture }
    payment[:transfer_group] = transfer_group if transfer_group.present?
    charge = Stripe::Charge.create(payment)
    Result::Success.new(charge)
  rescue Stripe::CardError => e
    Result::Error.new(e.json_body[:error][:message])
  end

  def transfer(amount, account:, currency:, transfer_group: nil)
    hash = { amount: amount, currency: currency, destination: account }
    hash[:transfer_group] = transfer_group if transfer_group.present?
    result = Stripe::Transfer.create(hash)
    result[:id].present? ? Result::Success.new(result) : Result::Error.new(:transfer)
  rescue Stripe::InvalidRequestError => e
    Result::Error.new(e.json_body[:error][:message])
  end

  def refund(charge_id, amount_cents: nil)
    hash = { charge: charge_id }
    if amount_cents.to_i.positive?
      hash[:amount] = amount_cents.to_i
    end
    Stripe::Refund.create(hash)
  rescue StandardError => e
    Result::Error.new(e.message)
    # #<Stripe::Refund:0x2d7e84c id=re_1DTo5NDahKuXOF2qaEsDqf8T> JSON: {
    #   "id": "re_1DTo5NDahKuXOF2qaEsDqf8T",
    #   "object": "refund",
    #   "amount": 1000,
    #   "balance_transaction": "txn_1DTo5NDahKuXOF2q2autTorQ",
    #   "charge": "ch_1DTo4QDahKuXOF2qZDXdHl8S",
    #   "created": 1541585793,
    #   "currency": "eur",
    #   "metadata": {},
    #   "reason": null,
    # "receipt_number": null,
    # "source_transfer_reversal": null,
    # "status": "succeeded"
    # }
  end

  def disconnect_from
    connector = StripeOauth.new(current_user)
    connector.deauthorize!
  end

  def stripe_verification_fields(account_id)
    sa = retrieve_stripe_account(account_id)
    sa['verification'].try(:[],'fields_needed')
  end

  def retrieve_stripe_account(account_id)
    Stripe::Account.retrieve(account_id)
  end

  def retrive_charge(charge_id)
    Stripe::Charge.retrieve(charge_id)
  end

  def retrive_balance_tx(balance_tx_id)
    Stripe::BalanceTransaction.retrieve(balance_tx_id)
  end

  def stripe_customer(id)
    Stripe::Customer.retrieve(id)
  end

  def redirect_url
    { redirect_uri: stripe_redirect_dashboard_account_index_url(locale: nil) }
  end
end
