# frozen_string_literal: true

class TranslateHomepageSettingImages < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    reversible do |dir|
      dir.up do
        HomepageSettingImage.create_translation_table!(title: :string, description: :string)
      end

      dir.down do
        HomepageSettingImage.drop_translation_table!
      end
    end
  end
end
