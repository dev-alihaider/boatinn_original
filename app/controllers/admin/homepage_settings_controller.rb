# frozen_string_literal: true

module Admin
  class HomepageSettingsController < GeneralController # :nodoc:
    before_action :set_homepage_settings, only: %i[index edit update]

    # available sections in homepage_settings settings part and default part
    DEFAULT_VIEW_TYPE = 'header_settings'

    VIEW_TYPES = { header_settings: { fields: %w[hp_logo hp_favicon], include_images: true, enabled: true },
                   cover_photo_slideshow: { fields: [], include_images: true, enabled: true },
                   search_bar_location: { fields: [], include_images: false },
                   market_place_slogan: { fields: [], enabled: true },
                   community_for_sharing: { fields: [], enabled: true },
                   community_preferences: { fields: ['hp_copre_1', 'hp_copre_2', 'hp_copre_3', 'hp_copre_4',
                                                     'hp_copre_5', 'hp_copre_6', 'hp_copre_7', 'hp_copre_8'],
                                            enabled: true },
                   add_listing_section: { fields: [], enabled: true },
                   experience_section: { fields: ['hp_exsec_1', 'hp_exsec_2', 'hp_exsec_3', 'hp_exsec_4',
                                                  'hp_exsec_5', 'hp_exsec_6', 'hp_exsec_7', 'hp_exsec_8'],
                                         enabled: true },
                   footer_settings: { fields: [], enabled: true } }.freeze
    # GET /admin/homepage_settings
    # GET /admin/homepage_settings.json
    def index; end

    # GET /admin/homepage_settings/1
    # GET /admin/homepage_settings/1.json
    def show; end

    # GET /admin/homepage_settings/new
    def new; end

    # GET /admin/homepage_settings/1/edit
    def edit
      @view_type = view_type(params[:view_type])

      slugs = only_slugs(@view_type)

      VIEW_TYPES[@view_type.to_sym].try(:[], :fields).each do |img|
        next if slugs.include?(img)
        @homepage_setting.images.build
        @homepage_setting.images.last.slug = img
        @homepage_setting.images.last.section_slug = @view_type
        @homepage_setting.images.last.build_image
      end
    end

    # POST /admin/homepage_settings
    # POST /admin/homepage_settings.json
    def create; end

    # PATCH/PUT /admin/homepage_settings/1
    # PATCH/PUT /admin/homepage_settings/1.json
    def update
      if @homepage_setting.update!(params[:homepage_setting].permit!)
        redirect_to admin_homepage_settings_path
      else
        render :edit
      end
    end

    # DELETE /admin/homepage_settings/1
    # DELETE /admin/homepage_settings/1.json
    def destroy; end

    private

    # Use callbacks to partials common setup or constraints between actions.
    def set_homepage_settings
      @homepage_setting = HomepageSetting.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_home_page_params
      params.fetch(:admin_homepages, {})
    end

    def view_type(view_type)
      VIEW_TYPES.key?(view_type.to_sym) ? view_type.to_s : DEFAULT_VIEW_TYPE
    end

    def only_slugs(view_type)
      @homepage_setting.images.with_section_slug(view_type).pluck(:slug)
    end
  end
end
