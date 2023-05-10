# frozen_string_literal: true

class TranslatePrewizardSettings < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    reversible do |dir|
      dir.up do
        PrewizardSetting.create_translation_table! rent_your_boat_title_main: :string,
                                                   rent_your_boat_strip_color: :string,

                                                   rent_your_boat_title_1: :string,
                                                   rent_your_boat_descr_1: :text,
                                                   rent_your_boat_title_2: :string,
                                                   rent_your_boat_descr_2: :text,
                                                   rent_your_boat_title_3: :string,
                                                   rent_your_boat_descr_3: :text,
                                                   rent_your_boat_title_4: :string,
                                                   rent_your_boat_descr_4: :text,

                                                   # explain_settings
                                                   explain_settings_title_1: :string,
                                                   explain_settings_strip_color_1: :string,
                                                   explain_settings_descr_1: :text,
                                                   explain_settings_title_2: :string,
                                                   explain_settings_strip_color_2: :string,
                                                   explain_settings_descr_2: :text,
                                                   explain_settings_title_3: :string,
                                                   explain_settings_strip_color_3: :string,
                                                   explain_settings_descr_3: :text,

                                                   # safety_settings
                                                   safety_settings_title_main: :string,

                                                   safety_settings_title_1: :string,
                                                   safety_settings_descr_1: :text,
                                                   safety_settings_title_2: :string,
                                                   safety_settings_descr_2: :text,
                                                   safety_settings_title_3: :string,
                                                   safety_settings_descr_3: :text
      end

      dir.down do
        PrewizardSetting.drop_translation_table!
      end
    end
  end
end
