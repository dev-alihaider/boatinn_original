# == Schema Information
#
# Table name: travel_bookings
#
#  id                 :bigint(8)        not null, primary key
#  trip_id            :bigint(8)
#  client_id          :bigint(8)
#  status             :integer
#  payment_process    :integer
#  number_of_guests   :integer
#  number_of_period   :integer
#  per_price_cents    :integer
#  seller_fee_cents   :integer
#  client_fee_cents   :integer
#  service_fee_cents  :integer
#  earnings_cents     :integer
#  subtotal_cents     :integer
#  total_cents        :integer
#  currency           :string
#  reservation_code   :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cleaning_fee_cents :integer          default(0)
#  skipper_fee_cents  :integer          default(0)
#

class Travel::Booking < ApplicationRecord
  include TravelMonetize

  belongs_to :trip, class_name: 'Travel::Trip'
  belongs_to :client, class_name: 'User'

  has_many :payments, class_name: 'Travel::Payment', dependent: :destroy
  has_one :invoice, class_name: 'Travel::Invoice', dependent: :destroy

  enum status: %w[open closed]
  enum payment_process: %w[single dual triple]

  scope :opened, -> { where(status: :open) }
  scope :closed, -> { where(status: :closed) }

  scope :classic, lambda {
    where(travel_trips: { rental: [Travel::Trip.rentals[:half_day],
                                   Travel::Trip.rentals[:one_day],
                                   Travel::Trip.rentals[:night],
                                   Travel::Trip.rentals[:week]] })
  }

  scope :sleepin, lambda {
    where(travel_trips: { rental: Travel::Trip.rentals[:sleepin] })
  }

  scope :shared, lambda {
    where(travel_trips: { rental: Travel::Trip.rentals[:shared] })
  }

  scope :with_rental_type, lambda { |rental_type|
    if rental_type.present?
      case rental_type.to_sym
      when :classic, :half_day, :one_day, :night, :week then classic
      when :sleepin then sleepin
      when :shared then shared
      else
        raise ArgumentError, <<~ERROR_MESSAGE.tr("\n", ' ').strip
          unknown `rental_type` value. Allowed values: `classic`, `half_day`,
          `one_day`, `night`, `week`, `shared`, `sleepin`
        ERROR_MESSAGE
      end
    end
  }

  scope :within_dates, lambda { |date_from, date_to|
    free_st = Travel::Trip.statuses.map do |status, index|
      index if Travel::Trip::NOT_LOCKED_STATUSES.include?(status)
    end.compact
    if date_from.present? && date_to.present?
      condition = '(DATE(travel_trips.check_in) BETWEEN :date_from AND :date_to'\
        ' OR DATE(travel_trips.check_out) BETWEEN :date_from AND :date_to) AND '\
        "travel_trips.status NOT IN (#{free_st.join(',')})"
      where(condition, date_from: date_from, date_to: date_to)
    end
  }

  def paying_process
    @paying_process ||=
      case payment_process.to_sym
      when :single
        TravelService::Payment::SingleProcess.new(self)
      when :dual
        TravelService::Payment::DualProcess.new(self)
      when :triple
        TravelService::Payment::TripleProcess.new(self)
      else
        raise 'invalid payment process!'
      end
  end

  def seller_penalty_amount
    return @seller_penalty_amount if defined?(@seller_penalty_amount)
    penalty_cents = payments.with_seller_penalty.sum(:penalty_from_seller_cents)
    Money.new(penalty_cents.to_i, currency)
  end

end
