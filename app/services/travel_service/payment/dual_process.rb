module TravelService::Payment
  class DualProcess < BaseProcess

    # build deposit payment for pay now 30%
    # build main payment for deferred pay 70%
    def build_payments(gw_fields = {})
      first_payment = initiate_first_payment
      second_payment = initiate_second_payment(first_payment)

      [first_payment, second_payment]
    end

    def initiate_first_payment
      payment = initiate_payment
      payment.attributes = {
        cleaning_fee: sum_for_first(@booking.cleaning_fee),
        skipper_fee:  sum_for_first(@booking.skipper_fee),
        seller_fee:   sum_for_first(@booking.seller_fee),
        client_fee:   sum_for_first(@booking.client_fee),
        service_fee:  sum_for_first(@booking.service_fee),
        earnings:     sum_for_first(@booking.earnings),
        subtotal:     sum_for_first(@booking.subtotal),
        total:        sum_for_first(@booking.total),
        type_of:      :deposit
      }

      # payment.total = fetch_payment_total(payment)
      payment
    end

    # second payment - rest from(booking minus first payment)
    def initiate_second_payment(first_payment)
      payment = initiate_payment
      payment.attributes = {
        cleaning_fee: @booking.cleaning_fee - first_payment.cleaning_fee,
        skipper_fee:  @booking.skipper_fee  - first_payment.skipper_fee,
        seller_fee:   @booking.seller_fee   - first_payment.seller_fee,
        client_fee:   @booking.client_fee   - first_payment.client_fee,
        service_fee:  @booking.service_fee  - first_payment.service_fee,
        earnings:     @booking.earnings     - first_payment.earnings,
        subtotal:     @booking.subtotal     - first_payment.subtotal,
        total:        @booking.total        - first_payment.total,
        plan_charge_at: second_pay_date,
        type_of: :prime
      }
      # payment.total = fetch_payment_total(payment)
      payment
    end

    def sum_for_first(amount)
      amount.percent_of(deposit_percents)
    end

    def sum_for_second(amount)
      amount - sum_for_first(amount)
    end

    def second_pay_date
      days = (TravelService::Preference::DUAL_DAYS_BEFORE_START.to_i).days
      check_in - days
    end

    def deposit_percents
      TravelService::Preference::DEPOSIT_PERCENTS_AMOUNT.to_f
    end

  end
end
