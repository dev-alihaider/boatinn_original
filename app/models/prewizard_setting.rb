# frozen_string_literal: true

# == Schema Information
#
# Table name: prewizard_settings
#
#  id               :bigint(8)        not null, primary key
#  rent_your_boat   :boolean          default(TRUE), not null
#  explain_settings :boolean          default(TRUE), not null
#  safety_settings  :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class PrewizardSetting < ApplicationRecord # :nodoc:
  has_many :translations
  accepts_nested_attributes_for :translations

  translates :rent_your_boat_title_main,
             :rent_your_boat_strip_color,

             :rent_your_boat_title_1,
             :rent_your_boat_descr_1,
             :rent_your_boat_title_2,
             :rent_your_boat_descr_2,
             :rent_your_boat_title_3,
             :rent_your_boat_descr_3,
             :rent_your_boat_title_4,
             :rent_your_boat_descr_4,

             # explain_settings
             :explain_settings_title_1,
             :explain_settings_strip_color_1,
             :explain_settings_descr_1,
             :explain_settings_title_2,
             :explain_settings_strip_color_2,
             :explain_settings_descr_2,
             :explain_settings_title_3,
             :explain_settings_strip_color_3,
             :explain_settings_descr_3,

             # safety_settings
             :safety_settings_title_main,

             :safety_settings_title_1,
             :safety_settings_descr_1,
             :safety_settings_title_2,
             :safety_settings_descr_2,
             :safety_settings_title_3,
             :safety_settings_descr_3, fallbacks_for_empty_translations: true
end
