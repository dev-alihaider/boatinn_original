# frozen_string_literal: true

class AddLinkToHomepageSettingImages < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :homepage_setting_images, :link, :string
  end
end
