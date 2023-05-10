# frozen_string_literal: true

class CreatePrewizardSettings < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :prewizard_settings do |t|

      # switch on/off entities
      t.boolean :rent_your_boat, null:false, default: true
      t.boolean :explain_settings, null:false, default: true
      t.boolean :safety_settings, null:false, default: true

      # rent_your_boat
      t.string  :rent_your_boat_title_main
      t.string  :rent_your_boat_strip_color

      t.string  :rent_your_boat_title_1
      t.text    :rent_your_boat_descr_1
      t.string  :rent_your_boat_title_2
      t.text    :rent_your_boat_descr_2
      t.string  :rent_your_boat_title_3
      t.text    :rent_your_boat_descr_3
      t.string  :rent_your_boat_title_4
      t.text    :rent_your_boat_descr_4

      # explain_settings
      t.string  :explain_settings_title_1
      t.string  :explain_settings_strip_color_1
      t.text    :explain_settings_descr_1
      t.string  :explain_settings_title_2
      t.string  :explain_settings_strip_color_2
      t.text    :explain_settings_descr_2
      t.string  :explain_settings_title_3
      t.string  :explain_settings_strip_color_3
      t.text    :explain_settings_descr_3

      # safety_settings
      t.string  :safety_settings_title_main

      t.string  :safety_settings_title_1
      t.text    :safety_settings_descr_1
      t.string  :safety_settings_title_2
      t.text    :safety_settings_descr_2
      t.string  :safety_settings_title_3
      t.text    :safety_settings_descr_3

      t.timestamps
    end
  end
end
