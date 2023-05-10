# == Schema Information
#
# Table name: travel_customers
#
#  id                 :bigint(8)        not null, primary key
#  trip_id            :bigint(8)
#  client_id          :bigint(8)
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
#  last_activity      :datetime
#  left_at            :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  seen_at            :datetime         default(Thu, 01 Jan 1970 00:00:00 UTC +00:00)
#  cleaning_fee_cents :integer          default(0)
#  skipper_fee_cents  :integer          default(0)
#

class Travel::Customer < ApplicationRecord
  include TravelMonetize
  belongs_to :trip, class_name: 'Travel::Trip'
  belongs_to :client, class_name: 'User'

  scope :enabled, -> { where(left_at: nil) }

  def enabled?
    left_at.blank?
  end
end
