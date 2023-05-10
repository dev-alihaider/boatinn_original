module TravelService::Payment
  class BaseProcess
    TOTAL_FIELDS = %i[subtotal service_fee cleanig_fee skipper_fee].freeze

    def initialize(booking_model)
      @booking = booking_model
    end

    def create_payment(gateway_fields = {})
      Result::Error.new(:payment)
    end

    def due_first
      @booking.total
    end

    def due_next
      Money.new(0, @booking.currency)
    end

    def date_next_due
      nil
    end

    def earnings_first
      @booking.earnings
    end

    def earnings_next
      Money.new(0, @booking.currency)
    end

    def check_in
      @booking.trip.check_in
    end

    def initiate_payment
      @booking.payments.new(
        per_price: @booking.per_price,
        client_fee: @booking.client_fee,
        seller_fee: @booking.seller_fee,
        service_fee: @booking.service_fee,
        earnings: @booking.earnings,
        cleaning_fee: @booking.cleaning_fee,
        skipper_fee: @booking.skipper_fee,
        subtotal: @booking.subtotal,
        total: @booking.total,
        currency: @booking.currency,
        stripe_fee_cents: 0,
        captured_at: nil,
        transferred_at: nil,
        plan_charge_at: nil,
        charge_id: nil,
        type_of: :prime,
        penalty_from_seller_cents: 0,
        intent_status: :pending,
        refunded_cents: 0
      )
    end

    def fetch_payment_total(payment)
      result = Money.new(0, payment.currency)
      TOTAL_FIELDS.each do |field|
        sub_sum = payment.try(field)
        result += sub_sum if sub_sum.present?
      end
      result
    end

  end
end
