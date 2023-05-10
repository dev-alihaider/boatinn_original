# frozen_string_literal: true

module Admin
  class PrewizardSettingsController < GeneralController # :nodoc:
    before_action :set_prewizard_settings, only: %i[index edit update]

    # available sections in homepage_settings settings part and default part
    DEFAULT_VIEW_TYPE = 'rent_your_boat'

    VIEW_TYPES = { rent_your_boat: { fields: [], include_images: false },
                   explain_settings: { fields: [], include_images: false },
                   safety_settings: { fields: [], include_images: false }}.freeze

    def edit
      @view_type = view_type(params[:view_type])
      @three = (1..3).to_a
      @four = (1..4).to_a
    end

    def update
      if @prewizard_setting.update!(params[:prewizard_setting].permit!)
        redirect_to admin_prewizard_settings_path
      else
        render :edit
      end
    end

    private

    def set_prewizard_settings
      @prewizard_setting = PrewizardSetting.first
    end

    def view_type(view_type)
      VIEW_TYPES.key?(view_type.to_sym) ? view_type.to_s : DEFAULT_VIEW_TYPE
    end
  end
end
