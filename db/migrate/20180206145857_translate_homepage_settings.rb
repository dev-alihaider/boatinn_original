class TranslateHomepageSettings < ActiveRecord::Migration[5.1]
  def change

    reversible do |dir|
      dir.up do
        HomepageSetting.create_translation_table! :search_bar_title                    => :string,
                                                  :search_bar_status                   => :string,
                                                  :marketplace_slogan                  => :string,
                                                  :community_for_sharing_title         => :string,
                                                  :community_for_sharing_descr         => :text,
                                                  :community_for_sharing_title_image_1 => :string,
                                                  :community_for_sharing_descr_image_1 => :text,
                                                  :community_for_sharing_title_image_2 => :string,
                                                  :community_for_sharing_descr_image_2 => :text,
                                                  :community_for_sharing_title_image_3 => :string,
                                                  :community_for_sharing_descr_image_3 => :text,
                                                  :add_listing_section_title           => :string,
                                                  :add_listing_section_descr           => :text,
                                                  :add_listing_section_title_image_1   => :string,
                                                  :add_listing_section_title_descr_1   => :text,
                                                  :add_listing_section_title_image_2   => :string,
                                                  :add_listing_section_title_descr_2   => :text,
                                                  :add_listing_section_title_image_3   => :string,
                                                  :add_listing_section_title_descr_3   => :text,
                                                  :add_listing_section_title_image_4   => :string,
                                                  :add_listing_section_title_descr_4   => :text
      end

      dir.down do
        HomepageSetting.drop_translation_table!
      end
    end

  end
end
