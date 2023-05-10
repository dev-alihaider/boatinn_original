# frozen_string_literal: true

module Admin
  class DashboardsController < GeneralController # :nodoc:
    before_action :set_admin_dashboard, only: %i[show edit update destroy]

    # GET /admin/dashboards
    # GET /admin/dashboards.json
    def index
     @countuser = User.count.to_f
     @countuserday = User.where('created_at<=?', 1.day.ago).count.to_f
     @percentuser = (((@countuser * 100) /  @countuserday ) - 100 ).to_f
    end

    # GET /admin/dashboards/1
    # GET /admin/dashboards/1.json
    def show; end

    # GET /admin/dashboards/new
    def new; end

    # GET /admin/dashboards/1/edit
    def edit; end

    # POST /admin/dashboards
    # POST /admin/dashboards.json
    def create; end

    # PATCH/PUT /admin/dashboards/1
    # PATCH/PUT /admin/dashboards/1.json
    def update; end

    # DELETE /admin/dashboards/1
    # DELETE /admin/dashboards/1.json
    def destroy; end

    private

    # Use callbacks to partials common setup or constraints between actions.
    def set_admin_dashboard
      @admin_dashboard = Admin::Dashboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_dashboard_params
      params.fetch(:admin_dashboard, {})
    end
  end
end