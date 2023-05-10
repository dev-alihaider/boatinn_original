# frozen_string_literal: true
# == Schema Information
#
# Table name: reviews
#
#  id                   :bigint(8)        not null, primary key
#  sender_id            :bigint(8)
#  trip_id              :bigint(8)
#  receiver_id          :bigint(8)
#  status               :integer          default("pending")
#  target               :integer
#  public_review        :text
#  private_review       :text
#  reply_review         :text
#  reviewed_at          :datetime
#  replied_at           :datetime
#  communication_grade  :integer
#  cleanliness_grade    :integer
#  boat_rules_grade     :integer
#  accuracy_grade       :integer
#  location_grade       :integer
#  check_in_grade       :integer
#  value_grade          :integer
#  recommended          :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  receiver_review_done :boolean          default(FALSE)
#  avg_grade            :decimal(3, 2)
#  enabled              :boolean          default(TRUE), not null
#

class Review < ApplicationRecord # :nodoc:
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :trip, class_name: 'Travel::Trip'

  has_many :reports_about, class_name: 'Report', as: :reportable,
                           dependent: :destroy

  GRADE_FIELDS_FOR_TRAVEL = %i[
    accuracy
    communication
    cleanliness
    location
    check_in
    value
  ].freeze

  GRADE_FIELDS_FOR_GUEST = %i[
    cleanliness
    communication
    boat_rules
  ].freeze

  # expired - when chance for give review is expired
  # closed  - when chance for give reply is expired
  enum status: %i[pending expired reviewed replied closed]
  enum target: %i[travel guest]

  scope :by_date_desc, -> { order(created_at: :desc) }
  scope :published, lambda {
    where(status: %i[reviewed replied closed],
          receiver_review_done: true,
          enabled: true)
  }
  scope :given_by, ->(user) { where(sender: user) }
  scope :received_for, ->(user) { where(receiver: user) }
  scope :for_trip, ->(trip) { where(trip: trip) }
  scope :given, -> { where status: %i[reviewed replied closed] }

  validates :public_review, presence: true, if: :reviewed?

  before_save do
    self.avg_grade = calculate_avg_grade
  end

  def given?
    %w[reviewed replied closed].include?(status)
  end

  def calculate_avg_grade
    rating = [
      communication_grade,
      cleanliness_grade,
      boat_rules_grade,
      accuracy_grade,
      location_grade,
      check_in_grade,
      value_grade
    ].compact
    rating.size.positive? ? (rating.sum.to_f / rating.size.to_f) : 0
  end

  def grade_fields
    self.travel? ? GRADE_FIELDS_FOR_TRAVEL : GRADE_FIELDS_FOR_GUEST
  end
end
