# frozen_string_literal: true

module Api
  # REST JSON API for reviews: user can retrieve list of reviews.
  class ReviewsController < Api::GenericController
    before_action :authenticate_user!

    # GET /api/users/:user_id/reviews.json
    def index
      user = User.find(params[:user_id])

      @reviews = if params[:type] == 'about'
                   user.reviews_about
                 else
                   user.reviews
                 end

      @reviews.by_date_desc
      paginate
    end

    private

    # Pagination: page, per page.
    def paginate
      page = params[:page].presence || 1
      per_page = params[:per_page].presence || 10

      @reviews = @reviews.page(page).per(per_page)
    end
  end
end
