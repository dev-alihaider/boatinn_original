class BookingsController < GeneralUsersController
  include ::BookingsConcern

  before_action :authenticate_user!
  before_action :ensure_initiate_travel, only: %i[new create create_message_to_owner]
  before_action :ensure_client, only: %i[new]
  before_action :boat_views_count, only: %i[new create]
  before_action :ensure_booking_and_client, only: %i[created_success share_by_email]
  # before_action :ensure_seller_payoutable, only: %i[new]

  def new
    @booking = @travel.current_bookings.first
    render locals: {
      presenter: BookingNewPresenter.new
    }
  end

  def create_message_to_owner
    result = run Travel::CreateMessageToOwner, { travel: @travel, message: params[:message] } do |op|
      redirect_to dashboard_inbox_path(id: op[:travel].trip.id) and return
    end

    flash[:error] = t("bookings.created_errors.#{result[:error_code]}")
    redirect_back(fallback_location: listings_path(@travel.boat_id))
  end

  def created_success
    @booking = Travel::Booking.find_by(id: params[:booking_id])
    @travel = TravelService::Travel.new(@booking.trip, current_user)
    @travel.attach_current_bookings([@booking])
  end

  def share_by_email
    params[:emails].values.each do |email|
      if email =~ URI::MailTo::EMAIL_REGEXP
        BookingMailer.share_booking(email, @booking.id).deliver_later
      end
    end
    redirect_to dashboard_inbox_path(id: @booking.trip_id)
  end
end
