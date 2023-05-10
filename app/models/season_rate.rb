# frozen_string_literal: true
# == Schema Information
#
# Table name: season_rates
#
#  id           :bigint(8)        not null, primary key
#  boat_id      :bigint(8)
#  offer_name   :string
#  started_at   :date
#  finished_at  :date
#  minimum_stay :integer
#  per_half_day :decimal(8, 2)
#  per_day      :decimal(8, 2)
#  per_night    :decimal(8, 2)
#  per_week     :decimal(8, 2)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SeasonRate < ApplicationRecord # :nodoc:
  belongs_to :boat

  before_save :round_prices

  scope :for_date, ->(date){ where(':date BETWEEN started_at AND finished_at', { date: date }) }

  private

  def round_prices
    self.per_half_day = per_half_day.to_f.round(ListingsHelper::PRECISION)
    self.per_day = per_day.to_f.round(ListingsHelper::PRECISION)
    self.per_night = per_night.to_f.round(ListingsHelper::PRECISION)
    self.per_week = per_week.to_f.round(ListingsHelper::PRECISION)
  end
end
