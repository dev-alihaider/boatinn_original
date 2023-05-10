# frozen_string_literal: true

module Admin
  class ReviewsController < GeneralController # :nodoc:
    before_action :define_review, except: :index

    # GET /admin/reviews
    def index
      selector =
        Review
        .joins('INNER JOIN travel_trips ON travel_trips.id = reviews.trip_id')
        .joins('INNER JOIN boats ON boats.id = travel_trips.boat_id')
        .joins('LEFT OUTER JOIN reports ON reports.reportable_id = reviews.id '\
               "AND reports.reportable_type = 'Review'")
        .joins('INNER JOIN users review_senders ON review_senders.id = '\
               'reviews.sender_id')
        .joins('INNER JOIN users review_receivers ON review_receivers.id = '\
               'reviews.receiver_id')
        .where.not(reviews: { status: :pending })
        .group('review_senders.id, review_receivers.id, boats.id, reviews.id')

      box = CollectionBoxService.new(selector, params)
      box.sortable = {
        created_at: 'reviews.created_at',
        reviewed_at: 'reviews.reviewed_at',
        boat: 'boats.listing_title',
        target: 'reviews.target',
        status: 'reviews.status',
        ratings: 'reviews.avg_grade',
        sender: 'review_senders.display_name',
        receiver: 'review_receivers.display_name',
        reports: 'COUNT(reports.id)',
        recommended: 'reviews.recommended',
        public_review: 'reviews.public_review',
        enabled: 'reviews.enabled'
      }

      box.searchable = {
        boat: { field: 'boats.listing_title' },
        sender: { field: 'review_senders.display_name' },
        receiver: { field: 'review_receivers.display_name' }
      }

      render locals: { box: box }
    end

    # PATCH /admin/reviews/:id
    def update
      @review.update!(review_params)
      boat = @review.trip.boat
      boat.update(rating_hash: Reviews.get_rating_for_boat(boat))
      redirect_to admin_reviews_path
    rescue StandardError => error
      flash[:error] = error.message
      redirect_to edit_admin_review_path(params[:id])
    end

    # GET /admin/reviews/:id/enable
    def enable
      @review.update(enabled: true)
      redirect_back(fallback_location: root_path)
    end

    # GET /admin/reviews/:id/disable
    def disable
      @review.update(enabled: false)
      redirect_back(fallback_location: root_path)
    end

    # DELETE /admin/reviews/:id
    # def destroy
    #   @review.destroy
    # rescue StandardError => error
    #   flash[:error] = error.message
    # ensure
    #   redirect_to admin_reviews_path
    # end

    private

    def define_review
      @review = Review.find(params[:id])
    end

    def review_params
      params[:review].permit(:public_review, :private_review, :reply_review,
                             :communication_grade, :cleanliness_grade,
                             :boat_rules_grade, :accuracy_grade,
                             :location_grade, :check_in_grade, :value_grade,
                             :recommended, :enabled)
    end
  end
end
