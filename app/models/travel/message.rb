# == Schema Information
#
# Table name: travel_messages
#
#  id         :bigint(8)        not null, primary key
#  trip_id    :bigint(8)
#  sender_id  :bigint(8)
#  context    :integer          default("message")
#  content    :text
#  metadata   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Travel::Message < ApplicationRecord
  belongs_to :trip, class_name: 'Travel::Trip'
  belongs_to :sender, class_name: 'User'
  enum context: %i[message transition]
  serialize :metadata

  scope :messages, -> { where(context: :message) }
  scope :events, -> { where(context: :transition) }

end
