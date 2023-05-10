# frozen_string_literal: true

class AddHomepageSettingId < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :homepage_setting_images, :homepage_setting_id, :integer

    add_index :homepage_setting_images, :homepage_setting_id
  end
end
