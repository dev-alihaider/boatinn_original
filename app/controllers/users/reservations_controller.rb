# frozen_string_literal: true

module Users
  class ReservationsController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!

    def index_reservations
      @bookings = bookings_scope(:accepted)
      @title = 'reservations'
      show_bookings
    end

    def index_earnings
      @bookings = bookings_scope(:completed)

      @title = 'earnings'
      show_bookings
    end

    def show_bookings
      locals = { box: CollectionBoxService.new(@bookings, params, limit: 5) }
      if request.xhr?
        render partial: 'users/reservations/table_booking', layout: false, locals: locals
      else
        locals[:earnings] = TravelService::Earnings.new(current_user)
        render 'users/reservations/index', locals: locals
      end
    end

    def calculate_earnings
      earnings = TravelService::Earnings.new(current_user)
      earnings.selected_listing_id = params[:listing_id].to_i
      @totals = {
        for_month: earnings.calculate_for_month(params[:month], params[:year]),
        for_year: earnings.calculate_for_year(params[:full_year])
      }
    end

    private

    def bookings_scope(trip_status)
      Travel::Booking.opened
        .joins(:trip)
        .where(travel_trips: {
          status: Travel::Trip.statuses[trip_status.to_s],
          seller_id: current_user.id
        }).order('travel_trips.transfer_at DESC')
    end

  end
end
