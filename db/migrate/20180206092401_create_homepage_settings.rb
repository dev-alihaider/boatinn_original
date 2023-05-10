class CreateHomepageSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_settings do |t|

      #switch on/off entities
      t.boolean :header_settings, null:false, default: true
      t.boolean :cover_photo_slideshow, null:false, default: true
      t.boolean :search_bar_location, null:false, default: true
      t.boolean :marketplace_slogan, null:false, default: true
      t.boolean :html_block, null:false, default: true
      t.boolean :community_for_sharing, null:false, default: true
      t.boolean :community_preferences, null:false, default: true
      t.boolean :add_listing_section, null:false, default: true
      t.boolean :experience_section, null:false, default: true
      t.boolean :footer_settings, null:false, default: true


      #header_settings_logo - add_phohtos
      #header_settings_favicon - add photos
      #cover_photo_slide_show - load phothos

      t.string :search_bar_title
      t.string :search_bar_status

      t.string :marketplace_slogan

      t.string :community_for_sharing_title

      ####
      t.string :community_for_sharing_color
      t.text   :community_for_sharing_descr

      t.string :community_for_sharing_title_image_1
      t.text   :community_for_sharing_descr_image_1

      t.string :community_for_sharing_title_image_2
      t.text   :community_for_sharing_descr_image_2

      t.string :community_for_sharing_title_image_3
      t.text   :community_for_sharing_descr_image_3

      #community_preferences
      #add title and description for image entity
      # t.string :community_preferences
      #
      # t.string :community_preferences_title_image_1
      # t.text   :add_listing_section_title_descr_1

      #listing section
      t.string  :add_listing_section_title
      t.text    :add_listing_section_descr
      t.string  :add_listing_section_strip_color


      t.string :add_listing_section_title_image_1
      t.text   :add_listing_section_title_descr_1

      t.string :add_listing_section_title_image_2
      t.text   :add_listing_section_title_descr_2

      t.string :add_listing_section_title_image_3
      t.text   :add_listing_section_title_descr_3

      t.string :add_listing_section_title_image_4
      t.text   :add_listing_section_title_descr_4

      # experience 8 images with title

      t.timestamps
    end
  end
end
