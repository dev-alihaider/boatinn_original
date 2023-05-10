# frozen_string_literal: true
# == Schema Information
#
# Table name: features
#
#  id          :bigint(8)        not null, primary key
#  category_id :bigint(8)
#  name        :string
#  order       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Feature < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :boats
  belongs_to :category
end
