class TripCancellationController < GeneralUsersController
  before_action :authenticate_user!
  before_action :ensure_travel_and_possible_cancellation

  def new
    if @travel.current_user_seller?
      return render 'trip_cancellation/seller_cancellation'
    end

    render 'trip_cancellation/new_client_cancellation'
  end

  def create
    cancel_params = {
      trip: @trip,
      canceller: current_user,
      subject: params[:cancel][:subject],
      reason: params[:cancel][:reason]
    }
    result = run Travel::CancelTrip, params: cancel_params do
      flash[:success] = t("notices.travel_canceled_successfully")
      return render 'trip_cancellation/booking_canceled', layout: false
    end

    flash[:error] = result[:error]
    render json: { redirect_to: new_cancellation_trip_path(params[:id]) }

  end

  private

  def ensure_travel_and_possible_cancellation
    @trip = Travel::Trip.find_by(id: params[:id])
    unless @trip
      flash[:error] = t("notices.booking_not_found")
      return redirect_to dashboard_inbox_index_path
    end

    @travel = TravelService::Travel.new(@trip, current_user)

    unless [@travel.current_user_client?, @travel.current_user_seller?].any?
      flash[:error] = t("notices.permission_denied")
      return redirect_to dashboard_inbox_index_path
    end

    unless @travel.can_cancel?
      flash[:error] = t("notices.travel_can_not_be_canceled")
      if request.xhr?
        render json: {redirect_to: dashboard_inbox_path(id: @travel.trip.id)} and return
      end
      redirect_to dashboard_inbox_path(id: @travel.trip.id)
    end
  end
end
