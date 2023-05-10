# == Schema Information
#
# Table name: travel_trip_cancellations
#
#  id                          :bigint(8)        not null, primary key
#  trip_id                     :bigint(8)
#  subject                     :integer
#  reason                      :text
#  seller                      :boolean
#  refunded_cents              :integer
#  penalty_cents               :integer
#  currency                    :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  payment_penalty_excision_id :integer
#  canceler_id                 :integer
#

class Travel::TripCancellation < ApplicationRecord
  enum subject: %i[busy_date have_best_deal owner change_date other]
  monetize :refunded_cents, with_model_currency: :currency
  monetize :penalty_cents, with_model_currency: :currency

  belongs_to :trip, class_name: 'Travel::Trip'
  belongs_to :canceler, class_name: 'User'
end
