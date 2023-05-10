# frozen_string_literal: true

module Users
  class ReviewsController < GeneralUsersController # :nodoc:

    before_action :authenticate_user!
    before_action :ensure_pending_given_review, only: %i[leave_review update]
    before_action :ensure_reviewed_received_review, only: %i[create_reply]
    before_action :define_travel, only: %i[leave_review]
    before_action :ensure_given_review_and_sender, only: %i[show]

    def index_received_reviews
      @current_tab = :received
      index(Review.received_for(current_user).published.or(Review.given_by(current_user).pending))
    end

    def index_given_reviews
      @current_tab = :given
      index(Review.given_by(current_user))
    end

    # GET, form with pending review
    def leave_review
      if @review.guest?
        new_review_about_guest
      else
        new_review_about_travel
      end
    end

    # PATCH, update pending review
    def update
      if @review.guest?
        create_review_about_guest
      else
        create_review_about_travel
      end
    end

    # PATCH, create reply
    def create_reply
      @review.attributes = {
        reply_review: params[:review][:reply_review],
        status: :replied,
        replied_at: Time.zone.now
      }

      if @review.save
        flash[:error] = t('notices.reply_send')
        redirect_back(fallback_location: given_dashboard_reviews_path) and return
      end

      flash[:error] = t('notices.reply_not_send')
      redirect_back(fallback_location: given_dashboard_reviews_path) and return
    end

    private

    def index(scope)
      @box = CollectionBoxService.new(scope.by_date_desc, params, limit: UsersHelper::REVIEWS_TO_SHOW)
      @pending_given_review_size = Review.given_by(current_user).pending.travel.count
      if request.xhr?
        if @current_tab == :received
          return render partial: 'received_review', collection: @box.collection, as: :review
        end
        if @current_tab == :given
          return render partial: 'given_review', collection: @box.collection, as: :review
        end
      end
      render :index
    end

    def new_review_about_travel
      # set default data
      @review.attributes = {
        accuracy_grade: 4,
        communication_grade: 4,
        cleanliness_grade: 4,
        location_grade: 4,
        check_in_grade: 4,
        value_grade: 4
      }
      render :new_review_about_travel
    end

    def new_review_about_guest
      # set default data
      @review.attributes = {
        communication_grade: 4,
        cleanliness_grade: 4,
        boat_rules_grade: 4,
        recommended: true
      }
      render :new_review_about_guest
    end

    def create_review_about_travel
      @review.attributes = params_for_travel_review
      if @review.save
        flash[:notice] = t('users.inbox.reviews.create.review_saved')
        @receive_review = Review.find_by(sender: @review.receiver, trip_id: @review.trip_id)
        @receive_review.update(receiver_review_done: true)
        ReviewGivenJob.perform_later(@review.id)
        redirect_to given_dashboard_reviews_path and return
      end
      flash[:error] = @review.errors.messages.first
      @travel = TravelService::Travel.new(@review.trip, @review.sender)
      render :new_review_about_travel
    end

    def create_review_about_guest
      @review.attributes = params_for_guest_review
      if @review.save
        flash[:notice] = t('users.inbox.reviews.create.review_saved')
        @receive_review = Review.find_by(sender: @review.receiver, trip_id: @review.trip_id)
        @receive_review.update(receiver_review_done: true)
        ReviewGivenJob.perform_later(@review.id)
        redirect_to given_dashboard_reviews_path and return
      end
      flash[:error] = @review.errors.messages.first
      @travel = TravelService::Travel.new(@review.trip, @review.sender)
      render :new_review_about_guest
    end

    def params_for_travel_review
      params.require(:review).permit(
        :public_review,
        :private_review,
        :accuracy_grade,
        :cleanliness_grade,
        :communication_grade,
        :accuracy_grade,
        :location_grade,
        :check_in_grade,
        :value_grade
      ).merge({
       status: :reviewed,
       reviewed_at: Time.zone.now
      })
    end

    def params_for_guest_review
      params.require(:review).permit(
        :public_review,
        :private_review,
        :cleanliness_grade,
        :communication_grade,
        :boat_rules_grade,
        :recommended
      ).merge({
        status: :reviewed,
        reviewed_at: Time.zone.now
      })
    end

    def ensure_pending_given_review
      @review = Review.find_by(id: (params[:review_id] || params[:id]))

      unless @review.present?
        flash[:error] = t('notices.booking_not_found')
        redirect_back(fallback_location: given_dashboard_reviews_path) and return
      end

      unless @review.sender == current_user
        flash[:error] = t('notices.member_not_found')
        redirect_back(fallback_location: given_dashboard_reviews_path) and return
      end

      unless @review.pending?
        flash[:error] = t('notices.review_already_given')
        redirect_back(fallback_location: given_dashboard_reviews_path)
      end
    end

    def ensure_reviewed_received_review
      @review = Review.find_by(id: (params[:review_id] || params[:id]))

      unless @review.present?
        flash[:error] = t('notices.booking_not_found')
        redirect_back(fallback_location: given_dashboard_reviews_path) and return
      end

      unless @review.receiver == current_user
        flash[:error] = t('notices.member_not_found')
        redirect_back(fallback_location: given_dashboard_reviews_path) and return
      end

      unless @review.reviewed?
        flash[:error] = t('notices.review_can_not_be_replied')
        redirect_back(fallback_location: given_dashboard_reviews_path)
      end
    end

    def define_travel
      @travel = TravelService::Travel.new(@review.trip, @review.sender)
    end

    def ensure_given_review_and_sender
      @review = Review.find_by(id: params[:id])
      redirect_back(fallback_location: root_path) unless @review.sender == current_user
      @travel = TravelService::Travel.new(@review.trip, current_user)
    end
  end
end
