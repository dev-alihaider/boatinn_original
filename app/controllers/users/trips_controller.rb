# frozen_string_literal: true

module Users
  class TripsController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :ensure_travel, only: %i[show_receipt]

    TRIPS_PER_PAGE = 12

    def index
      @travels = []
      scope = Travel::Trip.joins(:customers).where(travel_customers: { client_id: current_user.id, left_at: nil })
      @box = CollectionBoxService.new(scope.completed.order(check_in: :desc), params, limit: TRIPS_PER_PAGE)
      @box.collection.each { |trip| @travels << TravelService::Travel.new(trip, current_user) }
    end

    def show_receipt
      respond_to do |format|
        format.html do
          render 'show'
        end
        format.pdf do
          render pdf: 'receipt', template: 'users/trips/show.pdf', encoding: 'utf8'
        end
      end
    end

    def invite; end


    private

    def ensure_travel
      @trip = Travel::Trip.find_by(id: params[:id])
      @travel = TravelService::Travel.new(@trip, current_user)

      return if @trip && (@travel.current_client == current_user)

      flash[:error] = t('notices.booking_not_found')
      redirect_to dashboard_trips_path
    end
  end
end
