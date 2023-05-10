class CreateHomepageSettingImages < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_setting_images do |t|
      #additiional fields for
      t.string :title
      t.text :description
      t.string :slug

      t.timestamps
    end
  end
end
