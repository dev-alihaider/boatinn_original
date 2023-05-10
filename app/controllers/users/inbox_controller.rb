# frozen_string_literal: true

module Users
  class InboxController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :set_travel_and_check_access, only: %i[show create]
    before_action :reset_unread_status, only: %i[show]

    def index_travels
      index
    end

    def index_reservations
      index
    end

    def index
      params[:trip_type] = recommended_trip_type unless params[:trip_type].present?
      @inbox = InboxService.new(current_user, params)
      @trips = @inbox.trips
      @travels = []
      @trips.each { |trip| @travels << TravelService::Travel.new(trip, current_user) }

      if request.xhr?
        render template: "users/inbox/index_xhr", layout: false
      else
        render template: "users/inbox/index"
      end
    end

    # GET (/:locale)/dashboard/inbox/:id
    def show
      @new_message = @travel.trip.messages.new

      if @travel.current_user_seller?
        @boat_list = current_user.boats.finished.pluck(:listing_title, :id)
      end

      if request.xhr? && params[:last_id].present?
        return last_messages_and_status(params[:last_id])
      end

      # Availability calendar data for trip boat to reduce AJAX requests by 1.
      boat = @travel.trip.boat
      @booking_blockings =
        boat.booking_blockings.within_dates(current_user.calendar_started_at,
                                            current_user.calendar_finished_at)
            .order_by_started_at
      @bookings = boat.bookings.opened
                      .within_dates(current_user.calendar_started_at,
                                    current_user.calendar_finished_at)
    end

    # POST (/:locale)/dashboard/inbox/create_conversation
    def create_conversation
      @conversation = Conversation.new(conversation_params)
      @conversation.save!
      redirect_to dashboard_inbox_path(@conversation)
    rescue StandardError => error
      flash[:error] = error.message
      redirect_back(fallback_location: root_path)
    end

    # Create message in conversation.
    # POST (/:locale)/dashboard/inbox/:id
    def create
      create_message!
    rescue StandardError => error
      flash[:error] = error.message
    ensure
      redirect_to dashboard_inbox_path(id: @travel.trip.id)
    end

    private

    def set_travel_and_check_access
      trip = Travel::Trip.find_by(id: params[:id])
      unless trip.present?
        flash[:error] = t('users.inbox.travel_not_found')
        redirect_to dashboard_inbox_index_path and return
      end

      @travel = TravelService::Travel.new(trip, current_user)
      has_access = [
        @travel.current_user_seller?,
        @travel.current_user_client?
      ].any?

      unless has_access
        flash[:error] = t("notices.permission_denied")
        redirect_to dashboard_inbox_index_path
      end
    end

    def conversation_params
      params[:conversation].permit(messages_attributes: %i[user_id content],
                                   conversation_members_attributes: %i[user_id])
    end

    def message_params
      params.require(:travel_message).permit(:content)
    end

    def review_params
      params[:review].permit(:target_user_id, :public_review, :private_review,
                             :rating_cleanliness, :rating_communication,
                             :rating_boat_rules, :would_recommend)
    end

    def create_message!
      @new_message = @travel.trip.messages.new(message_params)
      @new_message.sender = current_user
      @new_message.save!
      TravelService::Transition.message_added(@travel, @new_message)
    end

    def current_booking
      @current_booking ||=
        if current_member.seller
          @conversation.bookings.find_by(seller_id: current_user.id)
        else
          @conversation.bookings.find_by(client_id: current_user.id)
        end
    end

    def current_member
      @current_member ||= @conversation.members.find_by(user_id: current_user.id)
    end

    def reset_unread_status
      if @travel.current_user_seller?
        @travel.trip.update_column(:seller_seen_at, Time.zone.now)
      else
        @travel.current_customer.update_column(:seen_at, Time.zone.now)
      end
    end

    def recommended_trip_type
      if Travel::Trip.where(seller: current_user).exists?
        :reservations
      else
        :travelling
      end
    end

    private

    def last_messages_and_status(last_id)
      messages = @travel.trip.messages.messages.where('id > :id', { id: last_id })
      render json: {
        messages: (render_to_string partial: 'users/inbox/show/message', collection: messages),
        status: concept('travel/cell/travel_public_status', @travel).(),
      }
    end

  end
end
