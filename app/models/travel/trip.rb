# == Schema Information
#
# Table name: travel_trips
#
#  id                 :bigint(8)        not null, primary key
#  boat_id            :bigint(8)
#  seller_id          :bigint(8)
#  check_in           :datetime
#  check_out          :datetime
#  status             :integer
#  rental             :integer
#  cancellation       :integer
#  number_of_guests   :integer
#  number_of_period   :integer
#  max_guests         :integer
#  min_guests         :integer
#  per_price_cents    :integer
#  seller_fee_cents   :integer
#  client_fee_cents   :integer
#  service_fee_cents  :integer
#  earnings_cents     :integer
#  subtotal_cents     :integer
#  total_cents        :integer
#  vat_fee_percents   :integer
#  currency           :string
#  transfer_at        :datetime
#  boat_hash          :text
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :bigint(8)
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  seller_seen_at     :datetime         default(Thu, 01 Jan 1970 00:00:00 UTC +00:00)
#  cleaning_fee_cents :integer          default(0)
#  skipper_fee_cents  :integer          default(0)
#  skipper_included   :boolean
#

class Travel::Trip < ApplicationRecord
  include TravelMonetize
  include BookingFields

  NOT_LOCKED_STATUSES = %w[free aborted declined pending].freeze


  belongs_to :seller, class_name: 'User'
  belongs_to :boat

  has_many :bookings,  class_name: 'Travel::Booking',  dependent: :destroy
  has_many :customers, class_name: 'Travel::Customer', dependent: :destroy
  has_many :messages,  class_name: 'Travel::Message',  dependent: :destroy
  has_many :payments,  through: :bookings

  has_many :trip_cancellations, class_name: 'Travel::TripCancellation',
                              dependent: :destroy

  has_attached_file :image, styles: { medium: '430x275#' }
  do_not_validate_attachment_file_type :image

  enum rental: %i[half_day one_day night week shared sleepin]
  enum status: %i[accepted declined aborted completed free pending]

  serialize :boat_hash

  scope :approved, -> { where(status: %i[accepted completed]) }
  scope :shared, -> { where(rental: :shared) }

  # Shared boat fully staffed by members.
  scope :shared_fully_staffed, lambda {
    shared.where('number_of_guests = max_guests')
  }

  scope :shared_not_fully_staffed, lambda {
    shared.where('number_of_guests < max_guests')
  }

  state_machine :status do
    state :pending   # just initiated
    state :free      # just message to owner
    state :accepted  # accepted by owner or automatic accepted
    state :declined  # when canceler seller
    state :aborted   # when canceler client
    state :completed # travel finished

    event :confirm do
      transition :pending => [:accepted, :free]
    end

    event :decline do
      transition :accepted => :declined, if: lambda { |trip| trip.bookings_can_be_can_canceled? }
    end

    event :abort do
      transition :accepted => :aborted, if: lambda { |trip| trip.bookings_can_be_can_canceled? }
    end

    event :complete do
      transition :accepted => :completed
    end
  end

  def bookings_can_be_can_canceled?
    current_bookings.all?{ |booking| booking.can_canceled? }
  end

  def current_bookings
    @current_bookings ||= bookings.opened
  end

  def rental_group
    case rental.to_sym
    when :shared
      :shared
    when :sleepin
      :sleepin
    else
      :classic
    end
  end

  def approved?
    %w[accepted completed].include?(status)
  end

  # cancellation with aborted all trip
  def trip_cancellation
    @trip_cancellation ||= trip_cancellations.last
  end

end
