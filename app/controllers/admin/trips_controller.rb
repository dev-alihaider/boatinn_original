# frozen_string_literal: true

module Admin
  class TripsController < GeneralController # :nodoc:

    before_action :ensure_travel, only: %i[show cancel]
    before_action :ensure_travel_cancellable, only: %i[cancel]

    def index
      suite = Travel::Trip
        .joins('INNER JOIN users sellers ON sellers.id = travel_trips.seller_id')
        .joins('INNER JOIN boats boats ON boats.id = travel_trips.boat_id')

      box = CollectionBoxService.new(suite, params)
      box.sortable = {
        boat:    'travel_trips.boat_id',
        rental:  'travel_trips.rental_type',
        seller:  'sellers.display_name',
        booked:  'travel_trips.created_at',
        started: 'travel_trips.check_in',
        price:   'travel_trips.subtotal_cents',
        status:  'travel_trips.status'
      }

      box.searchable = {
        code:   { field: 'reservation_code', from_many: Travel::Booking, relation: { trip_id: :id } },
        boat:   { field: 'listing_title', from_many: Boat, relation: { id: :boat_id } },
        seller: { field: 'sellers.display_name' },
        client: { field: 'display_name', from_many: User, through: Travel::Booking, relation: { trip_id: :id, id: :client_id } },
      }

      render locals: { box: box }
    end

    def show
      render locals: { booking: @booking }
    end

    # cancel trip, close bookings, refund payments
    def cancel
      result = run Travel::CancelTrip, params: { trip: @trip, canceller: @trip.seller } do
        flash[:success] = t("notices.travel_canceled_successfully")
        redirect_to admin_trip_path(id: @trip.id) and return
      end

      flash[:error] = result[:error]
      redirect_to admin_trip_path(id: @travel.trip.id)
    end

    private

    def ensure_travel
      @trip = Travel::Trip.find_by(id: params[:id])
      if @trip.blank?
        flash[:error] = t('booking.not_found')
        redirect_to admin_trips_path
      end
      @travel = TravelService::Travel.new(@trip, @trip.seller)
    end

    def ensure_travel_cancellable
      return if @travel.can_cancel?
      flash[:error] = t('notices.travel_can_not_be_canceled')
      redirect_to admin_trips_path(id: @travel.trip.id)
    end

  end
end
