# frozen_string_literal: true
# == Schema Information
#
# Table name: locations
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  lat        :decimal(11, 8)
#  lng        :decimal(11, 8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  boat_id    :bigint(8)
#  short_name :string
#

class Location < ApplicationRecord # :nodoc:
  belongs_to :boat

  acts_as_mappable
end
