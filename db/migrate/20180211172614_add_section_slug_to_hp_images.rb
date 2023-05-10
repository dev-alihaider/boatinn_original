# frozen_string_literal: true

class AddSectionSlugToHpImages < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :homepage_setting_images, :section_slug, :string
  end
end
