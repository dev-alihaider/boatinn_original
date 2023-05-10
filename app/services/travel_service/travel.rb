module TravelService
  class Travel
    attr_reader :trip, :current_user
    PAYMENT = ::Travel::Payment

    def initialize(trip, current_user)
      @trip = trip
      @current_user = current_user
    end

    def boat_hash
      @trip.boat_hash
    end

    def open?
      %w[accepted completed].include?(@trip.status)
    end

    def current_bookings
      @current_bookings ||=
        if current_user_seller?
          open? ? @trip.bookings.select(&:open?) : @trip.bookings
        else
          if open? && current_customer.left_at.blank?
            @trip.bookings.select{ |b| b.open? && b.client_id == @current_user.id }
          else
            @trip.bookings.select{ |b| b.client_id == @current_user.id }
          end
        end
    end

    def closed_bookings
      @closed_bookings ||=
        if current_user_seller?
          @trip.bookings.select(&:closed?)
        else
          @trip.bookings.select{ |b| b.closed? && b.client_id == @current_user.id }
        end
    end

    def current_customer
      @current_customer ||= @trip.customers.find_by(client_id: current_user.id)
    end

    def current_client
      current_user if current_customer.present?
    end

    def seller?(user)
      @trip.seller_id == user&.id
    end

    def client?(user)
      @trip.customers.where(client_id: user&.id).exists?
    end

    # method aliases

    def check_in
      @trip.check_in
    end

    def check_out
      @trip.check_out
    end

    def cancellation_policy
      @trip.cancellation
    end

    def rent_duration_in_days
      @rent_duration_in_days ||= DateService.duration_in_days(check_in, check_out)
    end

    def seller
      trip.seller
    end

    def unit_price
      subtotal / (shared? ? number_of_guests : number_of_periods)
    end

    def subtotal
      current_bookings.sum(&:subtotal)
    end

    def client_fee
      current_bookings.sum(&:client_fee)
    end

    def seller_fee
      current_bookings.sum(&:seller_fee)
    end

    def total
      current_bookings.sum(&:total)
    end

    def earnings
      current_bookings.sum(&:earnings)
    end

    def number_of_guests
      current_bookings.sum(&:number_of_guests)
    end

    def number_of_periods
      current_bookings.sum(&:number_of_period)
    end

    def unit_quantity
      shared? ? number_of_guests : number_of_periods
    end

    # was paid or prepare for paid
    def paid_amount
      if @trip.id.blank?
        return money_sum(payments_prime + payments_deposit, :total)
      end
      money_sum(payments_paid, :total)
    end

    # was paid or prepare for paid
    def client_fee_paid_amount
      if @trip.id.blank?
        return money_sum(payments_prime, :client_fee)
      end
      money_sum(payments_paid, :client_fee)
    end

    def will_be_pay_prime_amount
      money_sum(payments_prime_deferred, :total)
    end

    def date_next_prime
      payments_prime_deferred.first.plan_charge_at
    end

    def will_be_pay_deposit_amount
      money_sum(payments_deposit_deferred, :total)
    end

    def date_next_deposit
      payments_deposit_deferred.last.plan_charge_at
    end

    def urgent_amount
      money_sum(payments_urgent, :total)
    end

    def urgent_payment_actual?
      sts = %i[aborted declined canceled]
      current_user_client? && has_urgent_payment? && !sts.include?(current_status)
    end

    def payments_for_online_confirmation
      payments.select(&:requires_online_confirmation?)
    end

    def requires_payment_confirmation?
      payments_for_online_confirmation.present?
    end

    # refunded or can amount refund
    def refunded_amount
      @refunded_amount ||= trip_cancellation&.refunded || 0
    end

    def can_be_refunded_amount
      @can_be_refunded_amount ||= TravelService::Cancellation.will_refund_from_travel(self)
    end

    def trip_cancellation
      return @trip_cancellation if defined?(@trip_cancellation)
      @trip_cancellation ||= @trip.trip_cancellations.where(canceler_id: current_user.id).last
      @trip_cancellation ||= @trip.trip_cancellations.find_by(seller: true)
      @trip_cancellation ||= @trip.trip_cancellations.last if current_user_seller?
      @trip_cancellation
    end

    def shared?
      @trip.shared?
    end

    def has_urgent_payment?
      payments_urgent.present?
    end

    def attach_current_bookings(bookings)
      @current_bookings = bookings
    end

    def attach_payments(payments)
      @payments = payments
    end

    def attach_current_customer(customer)
      @current_customer = customer
    end

    def attach_trip(trip)
      @trip = trip
    end

    def current_user_client?
      current_customer.present?
    end

    def current_user_seller?
      @trip.seller_id == current_user.id
    end

    # helpers
    def options_for_select_guests
      options = []

      (trip.min_guests..trip.max_guests).each do |number|
        locals = { number: number }
        label = number > 1 ? I18n.t('bookings.label_passengers_count', locals) : I18n.t('bookings.label_passenger_count', locals)
        options << [label, number]
      end
      options
    end

    def cover_src
      return trip.image.url(:medium) if @trip.id.present? && trip.image.present?

      @trip.boat.images&.order(:priority)&.first&.attachment&.url(:medium) ||
                      Asset.new.attachment.url(:medium)
    end

    def guest_label
      passenger = number_of_guests > 1 ? :passengers_count : :passenger_count
      I18n.t("bookings.label_#{passenger}", number: number_of_guests).html_safe
    end

    def rental_type_label
      I18n.t("bookings.rental_types.#{ shared? ? :shared : @trip.rental }", count: unit_quantity).html_safe
    end

    def unit_label
      shared? ? I18n.t("bookings.label_guest", count: number_of_guests).html_safe : rental_type_label
    end

    def last_other_user
      @last_other_user ||=
        if current_user_client?
          @trip.seller
        else
          customers.order(:last_activity).last&.client
        end
    end

    # last message, if message do not exists, return last transition
    def last_message_or_event
      @last_message_or_event ||= last_message || last_event
    end

    def last_activity_date
      last_message_or_event&.created_at || trip.updated_at
    end

    def last_message
      @trip.messages.messages
        .where('created_at < ?', current_customer&.left_at || Time.zone.now)
        .last
     end

    def last_event
      scope = @trip.messages.events

      if current_user_client?
        scope.where!('created_at < ?', current_customer&.left_at || Time.zone.now)
        scope.where!(sender_id: [@current_user.id, @trip.seller_id])
      end

      scope.last
    end

    def current_last_event
      return last_event if current_user_seller?
      @trip.messages.events
        .where('created_at < ?', current_customer&.left_at || Time.zone.now)
        .where(sender: [trip.seller, current_client].compact)
        .last
     end

    def type_of
      case @trip.rental.to_sym
      when :shared
        :shared
      when :slipeen
        :slipeen
      else
        :classic
      end
    end

    def conversation_link
      Rails.application.routes.url_helpers.dashboard_inbox_path(id: @trip.id)
    end

    def boat_path
      Rails.application.routes.url_helpers.listing_path(id: @trip.boat_id)
    end

    def payments(order: nil)
      @payments ||= PAYMENT.where(booking: current_bookings)
      if order.present? && order == :paid_date
        @payments = @payments.sort do |a, b|
          a_date = a.captured_at || a.plan_charge_at || a.created_at
          b_date = b.captured_at || b.plan_charge_at || b.created_at
          a_date <=> b_date
        end
        return @payments #.reverse
      end

      @payments
    end

    def payments_canceled
      @payments_canceled ||= PAYMENT.where(booking: closed_bookings)
    end

    def payments_prime
      @payments_prime ||= payments.select{ |p| p.prime? && p.plan_charge_at.blank? }
    end

    def payments_prime_deferred
      @payments_prime_deferred ||= payments.select{ |p| p.prime? && p.plan_charge_at.present? }
    end

    def payments_paid
      @payments_paid ||= payments.select(&:paid?)
    end

    def payments_deposit
      @payments_deplosit ||= payments.select{ |p| p.deposit? && p.plan_charge_at.blank? }
    end

    def payments_deposit_deferred
      @payments_deplosit_deferred ||= payments.select{ |p| p.deposit? && p.plan_charge_at.present? }
    end

    def payments_urgent
      @payments_urgent ||= payments.select{ |p| p.urgent? && !p.intent_succeeded? }
    end

    def customers
      @customers ||= @trip.customers
                       .where(left_at: nil).where.not(id: current_customer&.id)
    end

    def can_cancel?
      return false if finished?
      return @trip.accepted? if current_user_seller?
      shared? ? current_customer.left_at.blank? : @trip.accepted?
    end

    def messages
      @messages ||= @trip.messages
                      .where('created_at < ?', current_customer&.left_at || Time.zone.now)
                      .order(created_at: :desc)
    end

    def current_status
      (current_user_client? && current_customer&.left_at) ? :aborted : trip.status.to_sym
    end

    def cancellation_path
      Rails.application.routes.url_helpers.new_cancellation_trip_path(id: @trip.id)
    end

    def can_transfer_earnings?
      !payments.all?(&:transferred?)
    end

    def canceled?
      !@trip.approved?
    end

    def canceled_by_seller?
      canceled? && @trip.trip_cancellation.seller
    end

    def canceled_by_client?
      canceled? && !@trip.trip_cancellation.seller
    end

    def unread_status
      trip.updated_at > last_seen_at ? :unread : :read
    end

    def last_seen_at
      current_customer&.seen_at || trip.seller_seen_at
    end

    def finished?
      # ! use Time.now not Time.zone.now
      Time.now > check_out && %w[accepted completed].include?(trip.status)
    end

    def given_review
      @given_review ||= Review.find_by(sender_id: current_user.id, trip_id: trip.id)
    end

    private

    def money_sum(collection, key)
      sum = collection_sum(collection, key)
      sum.zero? ? Money.new(0, @trip.currency) : sum
    end

    def collection_sum(collection, key)
      Array(collection).sum{ |obj| obj.try(key) }
    end
  end
end

