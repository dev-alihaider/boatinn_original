# frozen_string_literal: true
# == Schema Information
#
# Table name: boats
#
#  id                      :bigint(8)        not null, primary key
#  boat_type               :integer
#  passengers_count        :integer
#  builders_name           :string
#  name_model              :string
#  length                  :decimal(, )
#  listing_title           :string
#  listing_description     :text
#  bathrooms_count         :integer
#  cabins_count            :integer
#  beds_count              :integer
#  guest_number            :integer
#  minimum_rental_time     :integer
#  wizard_progress         :integer          default(0), not null
#  user_id                 :bigint(8)
#  cleaning_fee            :decimal(8, 2)
#  bedclosers_and_towels   :decimal(8, 2)
#  paddle_surf             :decimal(8, 2)
#  wellcome_pack           :decimal(8, 2)
#  fuel                    :decimal(8, 2)
#  skipper                 :decimal(8, 2)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  year_of_construction    :integer
#  per_half_day            :decimal(8, 2)
#  per_day                 :decimal(8, 2)
#  per_night               :decimal(8, 2)
#  per_week                :decimal(8, 2)
#  check_in_time           :time
#  check_out_time          :time
#  shared                  :boolean          default(FALSE), not null
#  sleepin                 :boolean          default(FALSE), not null
#  shared_price            :decimal(8, 2)
#  classic                 :boolean          default(FALSE), not null
#  sleepin_description     :string
#  sleepin_max_passengers  :integer
#  sleepin_per_night       :decimal(8, 2)
#  shared_description      :string
#  shared_min_passengers   :integer
#  shared_max_passengers   :integer
#  instant_booking_classic :boolean          default(FALSE), not null
#  cancellation            :integer          default("flexible"), not null
#  shared_check_in_time    :time
#  shared_check_out_time   :time
#  sleepin_check_in_time   :time
#  sleepin_check_out_time  :time
#  sleepin_extra_guests    :integer
#  sleepin_extra_price     :decimal(8, 2)
#  captain                 :integer          default("without"), not null
#  port                    :string
#  instant_booking_sleepin :boolean          default(FALSE), not null
#  instant_booking_shared  :boolean          default(FALSE), not null
#  sleepin_min_rental_time :integer
#  rating_hash             :text             default({:count=>0, :accuracy_avg=>0, :communication_avg=>0, :cleanliness_avg=>0, :location_avg=>0, :check_in_avg=>0, :value_avg=>0})
#  finished_at             :datetime
#  showboat                :boolean          default(TRUE)
#

class Boat < ApplicationRecord # :nodoc:
  include BookingFields

  MAX_IMAGES = 30
  ONE_FEET_IN_METERS = 0.3048

  enum boat_type: %i[catamaran power_boat sailing_boat jet_sky rib pontoon],
       _prefix: true
  enum captain: %i[without with with_or_without], _suffix: true

  serialize :rating_hash

  belongs_to :user

  has_one :location, dependent: :destroy
  accepts_nested_attributes_for :location
  acts_as_mappable through: :location

  has_many :booking_blockings, class_name: 'Travel::BookingBlocking',
                               dependent: :destroy
  has_many :trips, class_name: 'Travel::Trip', dependent: :destroy
  has_many :bookings, class_name: 'Travel::Booking', through: :trips

  has_many :images, class_name: 'BoatImage', as: :assetable, dependent: :destroy
  accepts_nested_attributes_for :images

  has_many :season_rates, dependent: :destroy
  accepts_nested_attributes_for :season_rates, allow_destroy: true

  has_and_belongs_to_many :wished_users, class_name: 'User', dependent: :destroy

  has_and_belongs_to_many :features, dependent: :destroy
  accepts_nested_attributes_for :features

  scope :classic, -> { where(classic: true) }
  scope :sleepin, -> { where(sleepin: true) }
  scope :shared,  -> { where(shared:  true) }
  scope :enabled, -> { classic.or(sleepin).or(shared) }
  scope :captain, ->(captain) { where(captain: captain) if captain.present? }
  scope :captain_any, ->(value) { captain(value).or(captain(:with_or_without)) }
  scope :boat_type, ->(boat_type) { where(boat_type: boat_type) }
  scope :by_date_desc, -> { order(created_at: :desc) }
  scope :within_10_km, ->(lat, lng) { within_distance_km(10, lat, lng) }
  scope :within_25_km, ->(lat, lng) { within_distance_km(25, lat, lng) }
  scope :finished, -> { where.not(finished_at: nil) }
  scope :not_finished, -> { where(finished_at: nil) }

  # Note: `where.not(id: finished)` generates nested SELECT: NOT IN (SELECT...)
  # scope :not_finished, lambda {
  #   where.not(wizard_progress: ListingsHelper::WIZARD_TOTAL_STEPS)
  # }
  #
  # scope :finished, lambda {
  #   where(wizard_progress: ListingsHelper::WIZARD_TOTAL_STEPS)
  # }

  scope :passengers_count, lambda { |passengers_count|
    if passengers_count.present?
      where('passengers_count >= ?', passengers_count)
    end
  }

  scope :within_distance_km, lambda { |distance, lat, lng|
    if distance.to_i.present? && lat.present? && lng.present?
      where(id: Location.within(distance.to_i, origin: [lat, lng])
                        .pluck(:boat_id))
    end
  }

  scope :size_within_20_percent, lambda { |length|
    unless length&.zero?
      where('round(abs(length - :length)*100 / :length) <= 20', length: length)
    end
  }

  # Check IN / OUT dates: all boats NOT inside blocked ranges.
  # TODO: DRY this -- move to method.
  scope :not_blocked_dates, lambda { |check_in_date, check_out_date|
    if check_in_date.present? && check_out_date.blank?
      joins("LEFT OUTER JOIN travel_booking_blockings
             ON travel_booking_blockings.boat_id = boats.id
             AND travel_booking_blockings.started_at
             BETWEEN '#{to_db_date(check_in_date)}'
             AND     'infinity'")
        .where(travel_booking_blockings: { id: nil })
    elsif check_in_date.blank? && check_out_date.present?
      joins("LEFT OUTER JOIN travel_booking_blockings
             ON travel_booking_blockings.boat_id = boats.id
             AND travel_booking_blockings.started_at
             BETWEEN '-infinity'
             AND     '#{to_db_date(check_out_date)}'")
        .where(travel_booking_blockings: { id: nil })
    elsif check_in_date.present? && check_out_date.present?
      joins("LEFT OUTER JOIN travel_booking_blockings
             ON travel_booking_blockings.boat_id = boats.id
             AND travel_booking_blockings.started_at
             BETWEEN '#{to_db_date(check_in_date)}'
             AND     '#{to_db_date(check_out_date)}'")
        .where(travel_booking_blockings: { id: nil })
    end
  }

  scope :can_book_now, lambda { |rental_type, check_in = nil, check_out = nil|
    if [check_in&.to_date, check_out&.to_date]
       .include?(Time.zone.now.to_date) && rental_type.present?
      case rental_type.to_sym
      when :classic
        classic.where('check_in_time >= ?', booking_available_until)
      when :shared
        shared.where('shared_check_in_time >= ?', booking_available_until)
      when :sleepin
        sleepin.where('sleepin_check_in_time >= ?', booking_available_until)
      else
        raise ArgumentError, <<~ERROR_MESSAGE.tr("\n", ' ').strip
          unknown `rental_type` value. Allowed values: `classic`, `shared`,
          `sleepin`
        ERROR_MESSAGE
      end
    end
  }

  validates :cabins_count, numericality: { only_integer: true, less_than: 51, message: "Maximum allowed is 50" }
  validates :beds_count, numericality: { only_integer: true, less_than: 51, message: "Maximum allowed is 50"}
  validates :guest_number, numericality: { only_integer: true, less_than: 101, message: "Maximum allowed is 100" }
  validates :bathrooms_count, numericality: { only_integer: true, less_than: 21, message: "Maximum allowed is 20" }
  validate :listing_title_is_not_only_numbers_and_length

  validates :length, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than_or_equal_to: 100 }  
  validate :year_of_construction_from_1900_to_current_year

  validates :images, length: {
    maximum: MAX_IMAGES,
    message: I18n.t('activerecord.errors.messages.too_many_attachments',
                    count: MAX_IMAGES)
  }

  before_save :round_prices
  before_save :set_finished_at

  def year_of_construction_from_1900_to_current_year
    if self.year_of_construction.present?
      min_year = 1900
      max_year = Date.today.year
      unless self.year_of_construction >= min_year && self.year_of_construction <= max_year
        errors.add(:year_of_construction, "must be between 1900 and #{max_year}")
      end
    end
  end

  def listing_title_is_not_only_numbers_and_length
    if self.listing_title.present?
      if self.listing_title =~ /^[0-9]+$/
        errors.add("Title", "Cannot be only numbers")
      end
      if self.listing_title.length > 64
        errors.add("Title", "Cannot exceed 64 characters")
      end
    end
  end

  # @return [String]
  def self.to_db_date(date)
    date.to_date.to_s(:db)
  end

  # @return [Time]
  def self.booking_available_until
    Time.now.to_time + Time.now.utc_offset +
      TravelService::Preference::PRE_BOOKING_MIN_TIME
  end

  def max_passenger_capacity_for(rental_type, date = nil)
    case rental_type.to_sym
    when :shared
      result = shared_max_passengers
      if date.present?
        result - TravelService::Trip.number_of_guests_for(boat_id: id,
                                                          date: date)
      end
    when :sleepin then sleepin_max_passengers
    else passengers_count
    end
  end

  def finished?
    wizard_progress == ListingsHelper::WIZARD_TOTAL_STEPS
  end

  def offlined?
    [classic, sleepin, shared].none?
  end

  def min_passenger_capacity_for(rental_type, date = nil)
    if rental_type.to_sym == :shared
      result = shared_min_passengers
      if date.present?
        result -= TravelService::Trip.number_of_guests_for(boat_id: id,
                                                           date: date)
      end
      result.positive? ? result : 1
    else
      1
    end
  end

  def price_cents_for(rental_type, date: nil)
    season = season_rates.for_date(date).first if date.present?
    price = case rental_type.to_sym
            when :shared then shared_price
            when :half_day then season&.per_half_day || per_half_day
            when :one_day then season&.per_day || per_day
            when :sleepin then sleepin_per_night
            when :night then season&.per_night || per_night
            when :week
              # when season rate or date exist, price for one day, else price
              # for one week
              week_price = season&.per_week || per_week
              date.present? ? (week_price / 7) : week_price
            end
    price.present? && price.positive? ? (price * 100).to_i : 0
  end

  def price_cents_for_week(start_date)
    end_date = start_date + 6.days
    season_rate_included = season_included(start_date, end_date)
    return season_rate_included.per_week if season_rate_included.present?

    return per_week unless season_exists?(start_date, end_date)

    (0..6).sum do |days|
      (season_rates.for_date(start_date + days.days).first&.per_week ||
        per_week) / 7
    end
  end

  def season_exists?(date_from, date_to)
    conditional = '(started_at BETWEEN :date_from AND :date_to) '\
      'OR (finished_at BETWEEN :date_from AND :date_to)'
    season_rates.where(conditional, date_from: date_from, date_to: date_to)
                .exists?
  end

  def season_included(date_from, date_to)
    conditional = '(started_at <= :date_from) AND (finished_at >= :date_to)'
    season_rates.where(conditional, date_from: date_from, date_to: date_to)
                .first
  end

  def reviews
    return @reviews if defined?(@reviews)

    @reviews = Review.received_for(user)
                     .for_trip(Travel::Trip.where(boat: self))
                     .travel.published.by_date_desc
  end

  def minimum_rental(rental_type = :classic)
    case rental_type
    when :sleepin
      { rental: 'search.index.sleepin_price',
        price: Money.new((sleepin_per_night.to_f * 100.0).to_i),
        passengers: sleepin_max_passengers }
    when :shared
      { rental: 'search.index.shared_price',
        price: Money.new((shared_price.to_f * 100.0).to_i),
        passengers: shared_max_passengers }
    else # :classic
      if minimum_rental_time.to_i > 43_200
        { rental: 'search.index.per_day',
          price: Money.new((per_day.to_f * 100.0).to_i),
          passengers: passengers_count }
      else
        { rental: 'search.index.per_half_day',
          price: Money.new((per_half_day.to_f * 100.0).to_i),
          passengers: passengers_count }
      end
    end
  end

  def offline!
    update(classic: false, sleepin: false, shared: false)
  end

  private

  def round_prices
    self.cleaning_fee = cleaning_fee.to_f.round(ListingsHelper::PRECISION)
    self.bedclosers_and_towels = bedclosers_and_towels
                                 .to_f.round(ListingsHelper::PRECISION)
    self.paddle_surf = paddle_surf.to_f.round(ListingsHelper::PRECISION)
    self.wellcome_pack = wellcome_pack.to_f.round(ListingsHelper::PRECISION)
    self.fuel = fuel.to_f.round(ListingsHelper::PRECISION)
    self.skipper = skipper.to_f.round(ListingsHelper::PRECISION)
    self.per_half_day = per_half_day.to_f.round(ListingsHelper::PRECISION)
    self.per_day = per_day.to_f.round(ListingsHelper::PRECISION)
    self.per_night = per_night.to_f.round(ListingsHelper::PRECISION)
    self.per_week = per_week.to_f.round(ListingsHelper::PRECISION)
    self.shared_price = shared_price.to_f.round(ListingsHelper::PRECISION)
    self.sleepin_per_night = sleepin_per_night.to_f
                                              .round(ListingsHelper::PRECISION)
    self.sleepin_extra_price = sleepin_extra_price
                               .to_f.round(ListingsHelper::PRECISION)
  end

  def set_finished_at
    self.finished_at = Time.zone.now if !finished_at? && finished?
  end
end
