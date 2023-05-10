# frozen_string_literal: true

# == Schema Information
#
# Table name: homepage_settings
#
#  id                              :bigint(8)        not null, primary key
#  header_settings                 :boolean          default(TRUE), not null
#  cover_photo_slideshow           :boolean          default(TRUE), not null
#  search_bar_location             :boolean          default(TRUE), not null
#  html_block                      :boolean          default(TRUE), not null
#  community_for_sharing           :boolean          default(TRUE), not null
#  community_preferences           :boolean          default(TRUE), not null
#  add_listing_section             :boolean          default(TRUE), not null
#  experience_section              :boolean          default(TRUE), not null
#  footer_settings                 :boolean          default(TRUE), not null
#  community_for_sharing_color     :string
#  add_listing_section_strip_color :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  marketplace_slogan_enabled      :boolean          default(TRUE), not null
#  compre_link_1                   :string
#  compre_link_2                   :string
#  compre_link_3                   :string
#  compre_link_4                   :string
#  compre_link_5                   :string
#  compre_link_6                   :string
#  compre_link_7                   :string
#  compre_link_8                   :string
#  compre_link_9                   :string
#  compre_link_10                  :string
#  compre_link_11                  :string
#  compre_link_12                  :string
#


class HomepageSetting < ApplicationRecord # :nodoc:
  has_many :images, class_name: 'HomepageSettingImage'
  accepts_nested_attributes_for :images,
                                           reject_if: proc { |attributes| attributes['image_attributes'].blank? },
                                           allow_destroy: true

  has_many :translations
  accepts_nested_attributes_for :translations

  translates :search_bar_title,
             :search_bar_status,
             :marketplace_slogan,
             :community_for_sharing_title,
             :community_for_sharing_descr,
             :community_for_sharing_title_image_1,
             :community_for_sharing_descr_image_1,
             :community_for_sharing_title_image_2,
             :community_for_sharing_descr_image_2,
             :community_for_sharing_title_image_3,
             :community_for_sharing_descr_image_3,
             :add_listing_section_title,
             :add_listing_section_descr,
             :add_listing_section_title_image_1,
             :add_listing_section_title_descr_1,
             :add_listing_section_title_image_2,
             :add_listing_section_title_descr_2,
             :add_listing_section_title_image_3,
             :add_listing_section_title_descr_3,
             :add_listing_section_title_image_4,
             :add_listing_section_title_descr_4,
             :compre_title_1,
             :compre_title_2,
             :compre_title_3,
             :compre_title_4,
             :compre_title_5,
             :compre_title_6,
             :compre_title_7,
             :compre_title_8,
             :compre_title_9,
             :compre_title_10,
             :compre_title_11,
             :compre_title_12, fallbacks_for_empty_translations: true
end
