# == Schema Information
#
# Table name: penalizations
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :bigint(8)
#  period_started_at     :datetime
#  period_end_at         :datetime
#  current_penalty_cents :integer          default(0)
#  currency              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_cancellations :integer          default(0)
#

class Penalization < ApplicationRecord
  monetize :current_penalty_cents, with_model_currency: :currency
  belongs_to :user

  def self.find_or_create_for(user)
    penalization = Penalization.find_by(user_id: user.id)
    unless penalization
      penalization = Penalization.create({
        user_id: user.id,
        currency: TravelService::Preference::PENALIZATION_PENALTY_CURRENCY,
      })
    end
    penalization
  end

  def penalty_period_available?
    period_end_at.blank? ? false : (period_end_at > Time.zone.now)
  end

  def self.current_canceled_trips_by_seller(seller)
    return [] if seller.penalization.blank? || seller.penalization.period_started_at.blank?

    date_from = seller.penalization.period_started_at
    date_to = seller.penalization.period_end_at

    Penalization.canceled_trips_by_seller(seller).where(created_at: date_from..date_to)
  end

  def self.canceled_trips_by_seller(seller)
    Travel::Trip
      .joins(:trip_cancellations)
      .where(seller_id: seller.id)
      .where(travel_trip_cancellations: { seller: true })
      .order('travel_trip_cancellations.created_at DESC')
  end

end
