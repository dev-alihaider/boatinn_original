# frozen_string_literal: true

module Admin
  class FaqSettingsController < GeneralController # :nodoc:
    before_action :define_faq, only: %i[edit update destroy]

    # GET /admin/faq_settings
    def index
      @faqs_general = Faq.general.order(:order)
      @faqs_for_renters = Faq.for_renters.order(:order)
      @faqs_for_owners = Faq.for_owners.order(:order)
    end

    # GET /admin/faq_settings/new
    def new
      @faq = Faq.new
    end

    # GET /admin/faq_settings/:id/edit
    def edit; end

    # POST /admin/faq_settings
    def create
      @faq = Faq.new(params['faq'].permit!)
      @faq.save!
      flash[:success] = t('admin.dashboard.faq.successfully_added_faq')
      redirect_to admin_faq_settings_path
    rescue StandardError => error
      flash[:error] = error.message
      render :new
    end

    # PATCH /admin/faq_settings/:id
    def update
      @faq.update(params[:faq].permit!)
      flash[:success] = t('admin.dashboard.faq.successfully_updated_faq')
      redirect_to admin_faq_settings_path
    rescue StandardError => error
      flash[:error] = error.message
      render :edit
    end

    # DELETE /admin/faq_settings/:id
    def destroy
      @faq.destroy
    rescue StandardError => error
      flash[:error] = error.message
    ensure
      redirect_to admin_faq_settings_path
    end

    private

    def define_faq
      @faq = Faq.find(params[:id])
    end
  end
end
