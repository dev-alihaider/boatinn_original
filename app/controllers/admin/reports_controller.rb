# frozen_string_literal: true

module Admin
  class ReportsController < GeneralController # :nodoc:
    before_action :define_report, only: %i[show destroy]

    # GET /admin/reports/about_review
    def about_review
      selector =
        Report
        .where(reportable_type: Review.to_s)
        .joins('INNER JOIN reviews ON reviews.id = reports.reportable_id')
        .joins('INNER JOIN travel_trips ON travel_trips.id = reviews.trip_id')
        .joins('INNER JOIN boats ON boats.id = travel_trips.boat_id')
        .joins('INNER JOIN users sellers ON sellers.id = '\
               'travel_trips.seller_id')
        .joins('INNER JOIN users review_authors ON review_authors.id = '\
               'reviews.sender_id')
        .joins('INNER JOIN users report_authors ON report_authors.id = '\
               'reports.author_id')

      box = CollectionBoxService.new(selector, params)
      box.sortable = {
        created_at: 'created_at',
        report_author: 'report_authors.display_name',
        reason: 'reason',
        boat: 'boats.listing_title',
        seller: 'sellers.display_name',
        review_author: 'review_authors.display_name',
        review_created_at: 'reviews.created_at'
      }
      box.searchable = {
        boat: { field: 'boats.listing_title' },
        seller: { field: 'sellers.display_name' },
        report_author: { field: 'report_authors.display_name' },
        review_author: { field: 'review_authors.display_name' }
      }

      render locals: { box: box }
    end

    # GET /admin/reports/about_user
    def about_user
      selector =
        Report
        .where(reportable_type: User.to_s)
        .joins('INNER JOIN users report_authors ON report_authors.id = '\
               'reports.author_id')
        .joins('INNER JOIN users report_receivers ON report_receivers.id = '\
               'reports.reportable_id')

      box = CollectionBoxService.new(selector, params)
      box.sortable = {
        created_at: 'created_at',
        report_author: 'report_authors.display_name',
        report_about: 'report_receivers.display_name',
        reason: 'reason',
        details: 'details'
      }
      box.searchable = {
        report_author: { field: 'report_authors.display_name' },
        report_about: { field: 'report_receivers.display_name' },
        details: { field: 'details' }
      }

      render locals: { box: box }
    end

    # DELETE /admin/reports/:id
    def destroy
      path = if @report.about_review?
               about_review_admin_reports_path
             else
               about_user_admin_reports_path
             end

      @report.destroy
    rescue StandardError => error
      flash[:error] = error.message
    ensure
      redirect_to path
    end

    private

    def define_report
      @report = Report.find(params[:id])
    end
  end
end
