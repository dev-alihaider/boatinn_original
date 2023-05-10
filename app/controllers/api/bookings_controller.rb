module Api
  class BookingsController < Api::GenericController
    include ::BookingsConcern

    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!

    before_action :ensure_initiate_travel, only: %i[create]
    before_action :ensure_client, only: %i[create]
    before_action :boat_views_count, only: %i[create]
    # before_action :ensure_seller_payoutable, only: %i[create]
    before_action :ensure_booking_and_client, only: %i[pay_urgent_payment]

    # create pending trip with payments
    def create
      result = TravelService::Trip.create_initiated_travel!(@travel, params[:source])

      resp =
        if result.failure?
          result.payload.destroy
          {
            success: false,
            message: 'Some error happened. Try again'
          }
        else
          travel_creation_response
        end

      render json: resp
    end

    # confirm pending trip with confirmed payments
    def confirm
      @trip = Travel::Trip.find_by(id: params[:id])
      return head(404) if @trip.blank?

      @travel = TravelService::Travel.new(@trip, current_user)
      return head(404) unless @travel.client?(current_user)

      # update payment statuses
      @travel.trip.payments.each do |payment|
        StripeApi.resolve_payment(payment)
      end

      render json: travel_creation_response
    end

    # pay exists trip by different payment method
    def pay_urgent_payment
      @travel = TravelService::Travel.new(@booking.trip, current_user)
      if params[:source]
        payments = @travel.payments_urgent
        payments.each do |payment|
          StripeApi.intentize_payment!(payment, capture: true, offline: false, source: params[:source])
        end
      end

      render json: urgent_payment_response
    end

    # resolve urgent payments
    def confirm_urgent_payment
      @travel = TravelService::Travel.new(@booking.trip, current_user)
      render json: urgent_payment_response
    end

    private

    def urgent_payment_response
      if @travel.requires_payment_confirmation?
        should_confirm_payment = @travel.payments_for_online_confirmation.first
        {
          success: true,
          should_confirm: true,
          continue_path: confirm_api_booking_path(id: @travel.trip.id)
        }.merge(StripeApi.payment_client_secret(should_confirm_payment))
      else
        {
          success: true,
          redirect_to: dashboard_inbox_path(id: @travel.trip.id),
        }
      end
    end

    def travel_creation_response
      if @travel.requires_payment_confirmation?
        should_confirm_payment = @travel.payments_for_online_confirmation.first
        {
          success: true,
          should_confirm: true,
          continue_path: confirm_api_booking_path(id: @travel.trip.id)
        }.merge(StripeApi.payment_client_secret(should_confirm_payment))
      else
        TravelService::Trip.confirm_travel!(@travel, params[:message])
        {
          success: true,
          redirect_to: booking_created_success_path(booking_id: @travel.trip.bookings.first.id),
        }
      end
    end
  end
end
