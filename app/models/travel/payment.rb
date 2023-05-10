# == Schema Information
#
# Table name: travel_payments
#
#  id                        :bigint(8)        not null, primary key
#  booking_id                :bigint(8)
#  type_of                   :integer
#  charge_id                 :string
#  balance_txn_id            :string
#  transfer_id               :string
#  stripe_fee_cents          :integer
#  per_price_cents           :integer
#  seller_fee_cents          :integer
#  client_fee_cents          :integer
#  service_fee_cents         :integer
#  earnings_cents            :integer
#  subtotal_cents            :integer
#  total_cents               :integer
#  penalty_from_seller_cents :integer
#  currency                  :string
#  source                    :string
#  try_charge_count          :integer          default(0)
#  captured_at               :datetime
#  transferred_at            :datetime
#  plan_charge_at            :datetime
#  last_charge_fail_at       :datetime
#  urgent                    :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cleaning_fee_cents        :integer          default(0)
#  skipper_fee_cents         :integer          default(0)
#  payment_intent_id         :string
#  intent_status             :integer
#  refunded_cents            :integer
#  refunded_at               :datetime
#

class Travel::Payment < ApplicationRecord
  include TravelMonetize
  monetize :penalty_from_seller_cents, with_model_currency: :currency
  monetize :refunded_cents, with_model_currency: :currency

  belongs_to :booking, class_name: 'Travel::Booking'

  enum type_of: %w[prime deposit]

  PAID_STATUSES = %w[
    requires_confirmation
    succeeded
  ].freeze

  REQUIRES_CONFIRM_STATUSES = %w[
    requires_confirmation
    requires_action
    requires_source_action
  ].freeze

  PENDING_STATUSES = %w[
    requires_payment_method
    requires_capture
    requires_confirmation
    requires_action
  ].freeze

  enum intent_status: %w[
    pending
    requires_payment_method
    requires_confirmation
    requires_action
    requires_source_action
    processing
    requires_capture
    canceled
    succeeded
  ], _prefix: :intent

  scope :paid, -> {
    where(intent_status: PAID_STATUSES)
      .or(Travel::Payment.where.not(transfer_id: nil))
  }

  scope :for_seller, ->(seller) do
    where(booking: Travel::Booking.joins(:trip)
                       .where(travel_trips: { seller_id: seller.id }))
  end

  scope :with_seller_penalty, -> { where('penalty_from_seller_cents > 0') }

  before_destroy :can_destroy?

  def paid?
    PAID_STATUSES.include?(intent_status) || transferred_at.present?
  end

  def transferred?
    intent_succeeded? && transferred_at.present?
  end

  def seller
    trip&.seller
  end

  def client
    booking&.client
  end

  def subtotal_with_fee
    total - client_fee
  end

  def trip
    booking&.trip
  end

  def boat
    trip&.boat
  end

  def requires_online_confirmation?
    REQUIRES_CONFIRM_STATUSES.include?(self.intent_status)
  end

  def can_capture?
    intent_requires_capture?
  end

  def can_transfer?
    intent_succeeded? && transferred_at.blank?
  end

  # refund captured payment
  def can_refund?
    intent_succeeded? && refunded_at.blank?
  end

  # cancel uncaptured payment
  def can_reject?
    PENDING_STATUSES.include?(self.intent_status)
  end

  private

  def can_destroy?
    return unless paid?

    errors[:base] << 'cannot delete paid payment'
    throw :abort
  end
end
