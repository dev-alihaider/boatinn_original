module BookingsConcern
  extend ActiveSupport::Concern

  def ensure_initiate_travel
    valid = TravelService::Validator.initiate_new_travel(params, current_user)
    unless valid[:success]
      flash[:error] = t("bookings.errors.#{valid[:error_code]}")
      redirect_to_path = params[:boat_id].present? ? listing_path(id: params[:boat_id]) : root_path
      redirect_to redirect_to_path and return
    end
    @travel = valid[:data]
  end

  def ensure_client
    if current_user == @travel.seller
      flash[:error] = t("bookings.errors.client_can_not_be_seller")
      redirect_to listing_path(id: @travel.trip.boat_id) and return
    end
  end

  def ensure_booking_and_client
    @booking = Travel::Booking.find_by(id: params[:booking_id] || params[:id])
    unless @booking.present? || @booking.client_id == current_user.id
      flash[:error] = t("errors.you_have_not_permission_to_this_page")
      redirect_to root_path
    end
    @travel = TravelService::Travel.new(@booking.trip, current_user)
  end

  def boat_views_count
    last_week = 1.week.ago.beginning_of_week..1.week.ago.end_of_week

    @boat_views_count = Ahoy::Event.where_props(boat_id: @travel.trip.boat_id)
                                   .where(time: last_week)
                                   .count
  end

  def ensure_seller_payoutable
    return if @travel.seller.payoutable?
    flash[:error] = t("bookings.errors.seller_not_payoutbable")
    redirect_to listing_path(id: @travel.trip.boat_id)
  end

end
