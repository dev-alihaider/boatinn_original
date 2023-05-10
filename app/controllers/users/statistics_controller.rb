# frozen_string_literal: true

module Users
  class StatisticsController < GeneralUsersController # :nodoc:
    VIEW_PER_MONTHS = 12
    VIEW_PER_REVIEWS = 3
    before_action :authenticate_user!
    before_action :set_current_user_boats, only: %i[ratings views]

    # GET (/:locale)/dashboard/statistics
    def index
      boats_scope = current_user.boats
      @statistic = Reviews.statistic_for_boats(boats_scope)
      @views = views_statistic(boats_scope)
    end

    # GET (/:locale)/dashboard/statistics/ratings
    def ratings
      boats_scope = current_user.boats
      boats_scope.where!(id: params[:boat_id]) if params[:boat_id].present?
      @statistic = Reviews.statistic_for_boats(boats_scope)
      @reviews_scope = Review.travel.published.by_date_desc
                  .where(trip: Travel::Trip.where(boat: boats_scope))

      @reviews_box = CollectionBoxService.new(@reviews_scope, params, limit: VIEW_PER_REVIEWS)
    end

    # GET (/:locale)/dashboard/statistics/views
    def views
      boats_scope = current_user.boats
      boats_scope.where!(id: params[:boat_id]) if params[:boat_id].present?

      if boats_scope.count.zero?
        flash[:notice] = t('notices.statistics_not_present')
        redirect_back(fallback_location: dashboard_statistics_path) and return
      end

      @views = views_statistic(boats_scope)
    end

    private

    def set_current_user_boats
      @boats = current_user.boats.by_date_desc
    end

    def views_statistic(boats)
      result = []
      today = Date.today
      boat_ids = boats.pluck(:id)
      return result if boat_ids.size.zero?

      from_date = if params[:boat_id].present?
                    current_user.boats.find_by(id: params[:boat_id])&.created_at || Date.today
                  else
                    current_user.boats.first&.created_at || Date.today
                  end
      total_months  = DateService.duration_in_months(from_date, Date.today)
      total_months = VIEW_PER_MONTHS if total_months < VIEW_PER_MONTHS
      @collection = Kaminari.paginate_array(Array(0..total_months-1))
                      .page(params[:page]).per(VIEW_PER_MONTHS)

      @collection.each do |months|
        result << StatisticService.views_boats_by_month(boat_ids, today - months.month)
      end
      result
    end
  end
end
