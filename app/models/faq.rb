# frozen_string_literal: true
# == Schema Information
#
# Table name: faqs
#
#  id         :bigint(8)        not null, primary key
#  category   :integer          default("general")
#  visible    :boolean          default(FALSE), not null
#  order      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Faq < ApplicationRecord # :nodoc:
  enum category: %i[general for_renters for_owners]

  scope :visible, -> { where(visible: true) }

  translates :title, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations
end
