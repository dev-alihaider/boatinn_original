# frozen_string_literal: true
# == Schema Information
#
# Table name: categories
#
#  id            :bigint(8)        not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  order         :integer
#  category_type :integer          default("non_experience")
#

class Category < ApplicationRecord # :nodoc:
  has_many :features
  enum  category_type: {non_experience: 0, experience: 1}
end
