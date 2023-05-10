# frozen_string_literal: true

class HomepagesController < GeneralUsersController # :nodoc:
  def index
    @homepage_settings = HomepageSetting.try(:last)
    images = @homepage_settings.try(:images)
    @slider_images ||= images.with_section_slug('cover_photo_slideshow').all

    @search_bar_title ||= @homepage_settings.search_bar_title

    # for preferences section
    @preferences_images ||= images.with_section_slug('community_preferences').all

    # for logo
    @logo ||= images.with_slug('hp_logo').first

    # for marketplace
    @marketplace_slogan ||= @homepage_settings.marketplace_slogan

    # for experience section
    @experience_images ||= images.with_section_slug('experience_section').all

    # supplementary arrays
    @four = (1..4).to_a
    @eleven = (1..12).to_a
    @eight = (1..8).to_a
  end
end
