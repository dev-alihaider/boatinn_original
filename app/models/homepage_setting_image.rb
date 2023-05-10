# frozen_string_literal: true
# == Schema Information
#
# Table name: homepage_setting_images
#
#  id                  :bigint(8)        not null, primary key
#  slug                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  homepage_setting_id :integer
#  section_slug        :string
#  link                :string
#

class HomepageSettingImage < ApplicationRecord # :nodoc:
  belongs_to :homepage_setting
  has_one :image, class_name: 'Asset', as: :assetable
  accepts_nested_attributes_for :image

  scope :with_section_slug, ->(section_slug) { where(section_slug: section_slug) }
  scope :with_slug, ->(slug) { where(slug: slug) }

  has_many :translations
  accepts_nested_attributes_for :translations

  translates :title, :description, fallbacks_for_empty_translations: true
end
