# frozen_string_literal: true

# stripe api wrapper
# using new payment flow `PaymentIntent`
module StripeApi
  module_function

  def user_payment_methods(user)
    return Result::Success.new([]) if user_customer_id(user).blank?

    with_result do
      Stripe::PaymentMethod.list(
        customer: user_customer_id(user),
        type: 'card'
      ).data.map do |pm|
        {
          id: pm.id,
          brand: pm.card['brand'],
          month: pm.card['exp_month'],
          year: pm.card['exp_year'],
          last4: pm.card['last4'],
        }
      end
    end
  end

  def detach_payment_method(payment_method)
    with_result do
      Stripe::PaymentMethod.detach(payment_method)
    end
  end

  def user_customer_id(user)
    user.stripe_account.present? ? user.stripe_account.stripe_customer_id : nil
  end

  def user_customer_id!(user)
    cus_id = user_customer_id(user)
    return cus_id if cus_id.present?

    stripe_account = user.stripe_account || user.create_stripe_account
    stripe_cus = create_stripe_customer(user)
    stripe_account.update(stripe_customer_id: stripe_cus.id)
    stripe_cus.id
  end

  def create_stripe_customer(user)
    Stripe::Customer.create(
      description: "Customer for #{user.email}",
      email: user.email,
      name: user.display_name,
      phone: user.phone_number
    )
  end

  def stripe_payment_intent(payment_intent_id)
    with_result do
      Stripe::PaymentIntent.retrieve(payment_intent_id)
    end
  end

  def payment_client_secret(local_payment)
    res = stripe_payment_intent(local_payment.payment_intent_id)
    return {} if res.failure?

    {
      client_secret: res.payload.client_secret,
      payment_method: res.payload.payment_method,
    }
  end

  def resolve_payment(local_payment)
    return false if local_payment.payment_intent_id.blank?

    result = stripe_payment_intent(local_payment.payment_intent_id)
    return false if result.failure?

    updates = {
      intent_status: result.payload.status
    }
    case result.payload.status # payment intent status
    # when 'requires_payment_method'
    #
    # when 'requires_confirmation', 'requires_action', 'requires_source_action'
    #
    # when 'processing'
    #
    # when 'requires_capture'
    #
    # when 'canceled'
    when 'succeeded'
      updates[:captured_at] = local_payment.captured_at || Time.zone.now
    # else
    #   raise("Invalid stripe payment intent status - `#{result.payload.status}`")
    end

    local_payment.update(updates)
  end


  def with_result
    raise('Missing block') unless block_given?

    begin
      Result::Success.new(yield)
    rescue StandardError => e
      Result::Error.new(e.message)
    end
  end

  def intentize_payment!(payment, capture: false, offline: false, source: nil)
    payment.source = source if source.present?
    result = with_result do
      # payment client is payer
      Stripe::PaymentIntent.create(
        amount: payment.total.cents,
        currency: payment.currency.to_s.downcase,
        customer: user_customer_id!(payment.client),
        payment_method: payment.source,
        off_session: offline,
        confirm: true,
        transfer_group: build_transfer_group(payment),
        capture_method: capture ? :automatic : :manual,
        metadata: {
          client: payment.client.display_name,
          client_email: payment.client.email,
          client_id: payment.client.id,
          seller: payment.seller.display_name,
          seller_email: payment.seller.email,
          seller_id: payment.seller.id,
          boat_id: payment.boat.id,
          boat_name: payment.boat.listing_title,
          trip_check_in: payment.trip.check_in,
          trip_check_out: payment.trip.check_out
        }
      )
    end

    return result if result.failure?

    intent = result.payload
    updates = {
      payment_intent_id: intent.id,
      intent_status: intent.status
    }

    if intent.status == 'succeeded'
      updates[:urgent] = false
    elsif payment.urgent?
      updates[:try_charge_count] = payment.try_charge_count + 1
    end
    payment.update(updates)

    if capture
      payment_captured_hook(payment, result.payload)
    else
      PaymentAuthorizedJob.perform_later(payment.id) unless capture
    end
    result
  end

  def transfer_payment(payment, amount: nil, include_seller_penalty: true)
    return Result::Error.new(:can_be_transferred) unless payment.can_transfer?

    seller = payment.seller
    stripe_seller_id = seller.stripe_account&.express_account_id
    return Result::Error.new(:stripe_account_not_exists) if stripe_seller_id.blank?

    amount = amount || payment.earnings
    seller_penalty =
      if include_seller_penalty
        max_seller_penalty_of(seller, amount)
      else
        Money.new(0, payment.currency)
      end

    amount -= seller_penalty

    result =
      if amount.positive?
        with_result do
          transfer_request = {
            amount: amount.cents,
            currency: amount.currency.to_s.downcase,
            destination: stripe_seller_id,
            transfer_group: build_transfer_group(payment)
          }

          Stripe::Transfer.create(transfer_request)
        end
      else
        s = { id: nil }
        Result::Success.new(s)
      end

    return result if result.failure?

    payment.update(
      transfer_id: result.payload[:id],
      penalty_from_seller: seller_penalty,
      transferred_at: Time.zone.now
    )
    if seller_penalty.positive?
      rest_penalty = seller.penalization.current_penalty - seller_penalty
      seller.penalization.update(current_penalty: rest_penalty)

      cancellation = Travel::TripCancellation
                       .where(seller: true)
                       .where('penalty_cents > 0')
                       .where(payment_penalty_excision_id: nil)
                       .first
      cancellation&.update(payment_penalty_excision_id: payment.id)
    end

    result
  end

  def capture_payment(local_payment)
    res = with_result do
      Stripe::PaymentIntent.capture(local_payment.payment_intent_id)
    end

    payment_captured_hook(local_payment, res.payload) if res.success?
  end

  def payment_captured_hook(local_payment, stripe_payment_intent = nil)
    stripe_payment_intent ||= stripe_payment_intent(local_payment.payment_intent_id).payload
    balance_transaction = Stripe::BalanceTransaction.retrieve(
      stripe_payment_intent.charges.data.first.balance_transaction
    )

    local_payment.update(
      captured_at: Time.zone.now,
      balance_txn_id: balance_transaction.id,
      stripe_fee_cents: balance_transaction.fee,
      intent_status: stripe_payment_intent.status
    )
  end

  def cancel_payment(local_payment, refund_amount:)
    # cancel preauthorize (not captured) if not captured and refund all
    res =
      if local_payment.paid? && (refund_amount == local_payment.total)
        refund_payment(local_payment, amount: nil) # refund all paid sum
      else
        # save money to marketplace if not saved
        capture_payment(local_payment) if local_payment.can_capture?
        if local_payment.can_refund?
          # refund or partial refund
          refund_payment(local_payment, amount: refund_amount)
        elsif local_payment.can_reject?
          # just annul payments
          reject_payment(local_payment)
        end
      end
    res || Result::Error.new(:invalid_cancellation_method)
  end

  def refund_payment(local_payment, amount:)
    return false unless local_payment.can_refund?

    cents = amount.present? ? amount.cents : local_payment.total.cents
    res = with_result do
      Stripe::Refund.create(
        payment_intent: local_payment.payment_intent_id,
        amount: cents
      )
    end
    return res if res.failure?

    local_payment.update(
      refunded_at: Time.zone.now,
      refunded_cents: cents
    )
    res
  end

  def reject_payment(local_payment)
    res = with_result do
      Stripe::PaymentIntent.cancel(local_payment.payment_intent_id)
    end
    return res if res.failure?

    local_payment.update(intent_status: res.payload.status)
    res
  end

  def build_transfer_group(payment)
    "booking_#{payment.booking_id}|tx_#{payment.id}"
  end

  def max_seller_penalty_of(seller, amount)
    zero = Money.new(0, amount.currency)
    return zero if seller.penalization.blank?
    return zero unless seller.penalization.current_penalty.positive?
    return zero if amount < seller.penalization.current_penalty
    seller.penalization.current_penalty > amount ? amount : seller.penalization.current_penalty
  end

end


