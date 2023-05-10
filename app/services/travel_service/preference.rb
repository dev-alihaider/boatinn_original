module TravelService::Preference
  CURRENCY = 'EUR'

  # preferences for generation reservation code
  RESERVATION_CODE_CHARS = "123456789ABCDEFKLMNOPRTGHSFYZVWX"
  RESERVATION_CODE_LENGTH = 13

  # period between authorize and capture
  #   cancellation in this period free - without stripe fee
  #   important: this value can`t be more than 6.5 days
  AUTHORIZE_PERIOD_HOURS = 24
  # period before checkin when booking can not be refund
  FORCE_BOOKING_HOURS = 48

  # preferences for triple payment logic(two payments defer)
  #   if booking start more than this value,
  #   payment process will be TriplePaymentProcess
  TRIPLE_DAYS_BEFORE_START = 87
  # preferences for dual payment logic
  #   if booking start more than this value,
  #   payment process will be DualPaymentProcess, else SinglePaymentProcess
  DUAL_DAYS_BEFORE_START = 30
  # percents of the amount that the client pays immediately
  # used in Triple and Dual payments process
  DEPOSIT_PERCENTS_AMOUNT = 30.0

  # statuses wich was paid
  PAID_STATUSES = %w[authorized captured].freeze

  # cancellation flexible
  #   days before checkin, when can`t refund any sum
  FLEXIBLE_MIN_DAYS = 15

  # cancellation moderate
  #   duration possible cancel before check in
  MODERATE_MIN_DAYS = 15
  #   duration before checkin when return 50% of amount
  MODERATE_FORCE_DAYS = 30
  #   percent will be refund in force period
  MODERATE_FORCE_PERCENT = 50

  # cancellation strict
  #   duration possible cancel before check in
  STRICT_MIN_DAYS = 60

  # penalty period
  PENALIZATION_PERIOD_DURATION = 6.month
  # penalty size for first, second, third, fours, n, cancellation
  PENALIZATION_TIMES_SIZE_CENTS = [0, 0, 50_00, 100_00]
  # currency for penalty money
  PENALIZATION_PENALTY_CURRENCY = :EUR

  FIRST_TRANSFER_DELAY = 48.hours
  TRANSFER_DELAY = 24.hours

  # params for attempt to pay if there is no money
  ATTEMPT_TO_PAY_DURATION = 48.hours
  ATTEMPT_TO_PAY_INTERVAL = 1.hour

  PRE_BOOKING_MIN_TIME = 1.hour

  def vat_fee_percents
    ENV['VAT_FEE_PERCENTS'].to_f
  end

  def client_fee_percents
    client_fee = ENV['CLIENT_FEE_PERCENTS'].to_f
    client_fee + client_fee.percent_of(vat_fee_percents, :float)
  end

  def seller_fee_percents
    seller_fee = ENV['SELLER_FEE_PERCENTS'].to_f
    seller_fee + seller_fee.percent_of(vat_fee_percents, :float)
  end

  def currency
    CURRENCY
  end

  def commission_from_client(subtotal)
    subtotal.percent_of(client_fee_percents)
  end

  def commission_from_seller(subtotal)
    subtotal.percent_of(seller_fee_percents)
  end

  def days_before_checkin(booking)
    DateService.duration_in_days(Time.zone.now, booking.trip.check_in)
  end

  class << self

    def hours_after_booking(booking)
      DateService.duration_in_hours(booking.created_at, Time.zone.now)
    end

    def hours_before_checkin(booking)
      DateService.duration_in_hours(Time.zone.now, booking.trip.check_in)
    end

    def waiting_hours(booking)
      DateService.duration_in_hours(booking.created_at, booking.trip.check_in)
    end

    def authorize_period?(booking)
      return false if waiting_hours(booking) < FORCE_BOOKING_HOURS

      AUTHORIZE_PERIOD_HOURS > hours_after_booking(booking) &&
          AUTHORIZE_PERIOD_HOURS < hours_before_checkin(booking)
    end

    def generate_reservation_code
      code = ''
      RESERVATION_CODE_LENGTH.times do
        code << RESERVATION_CODE_CHARS[rand(RESERVATION_CODE_CHARS.size)]
      end
      ::Travel::Booking.find_by(reservation_code: code).present? ? generate_reservation_code : code
    end
  end

end
