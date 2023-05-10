# frozen_string_literal: true

module Users
  class ListingsController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!, except: :show
    before_action :set_current_user_boat, except: %i[index show]
    before_action :set_current_user_boats, only: %i[index edit settings]
    before_action :set_classic_or_sleepin_or_shared_boat,
                  :set_similar_listings, only: :show
    before_action :set_payment_notify, only: :index
    after_action :track_view, only: :show

    def index
      @boats_in_progress = @boats.not_finished
      @boats = @boats.finished
    end

    # GET (/:locale)/listings/:id
    def show
      seller = @boat.user
      @response_rate = seller.avg_response_rate
      @response_time = seller.avg_response_seconds
      @reviews_about = seller.reviews_about.by_date_desc
      @booking_blockings = @boat.booking_blockings
                                .within_dates(Time.zone.today, 'infinity')
                                .order_by_started_at

      block_today_booking_if_check_in_expired

      @page_title = 'Listing'

      # Meta description and title
      @description_v= ''
      if  @boat.location.name.present?
        if  @boat.shared_description.present? 
          @description_v= @boat.shared_description
        end
        if  @boat.listing_description.present?
          @description_v= @boat.listing_description
        end  
        if  @boat.sleepin_description.present?
          @description_v= @boat.sleepin_description 
        end
          
        @metadescription = t('users.listings.show.nautical_experience') +  @boat.location.name + ' | ' + @description_v.split('.')[0] 
        @b_model = ''
        @b_model =  @boat.name_model if @boat.name_model.present?
        @b_type = ''
        @b_type =   @boat.boat_type if @boat.boat_type.present?
        @b_location = ''
        @b_location =  @boat.location.short_name if @boat.location.short_name.present?
        @b_id = ''
        @b_id = @boat.id.to_s
        @metatitle = t('users.listings.show.boat_rental') + @b_location + ', ' + t('users.listings.edit.model') + ': ' + @b_model + ', ' + t('users.listings.edit.type') + ': ' + t('wizards.index.page01.boat_type.' + @b_type) + ', id: ' + @b_id
        @metaswitch = 0
      else
        @metadescription = t('meta_description')
        @metatitle= t('users.listings.show.nautical_experience') + 'boatINN'
      end
      
      # Active bookings collection to block this dates on booking calendar.
      # If boat shared and not fully staffed by members then remove it from
      # bookings collection to make it available for booking.
      @bookings = @boat
                  .bookings.opened
                  .within_dates(Time.zone.today, 'infinity')
    end

    def update
      boat_params = params['boat'].permit!
      @boat.update!(boat_params)
    rescue StandardError => error
      flash[:error] = error.message
    ensure
      redirect_path = if request.referer == port_dashboard_listing_url(@boat)
                        edit_dashboard_listing_path(@boat)
                      else
                        dashboard_listings_path
                      end
      redirect_to redirect_path
    end

    def destroy
      return (render json: false) if @boat.finished?
      render json: @boat.destroy
    end

    def setshowboat
      @boat.showboat = false
      if @boat.save
         redirect_to :action => 'index'
      end
    end
    
    private

    def set_classic_or_sleepin_or_shared_boat
      @boat = Boat.enabled.find(params[:id])
    end

    def set_similar_listings
      @similar_boats = Boat.enabled
                           .within_10_km(@boat.location.lat, @boat.location.lng)
                           .where.not(id: @boat.id)
                           .boat_type(@boat.boat_type)
                           .passengers_count(@boat.passengers_count)
                           .size_within_20_percent(@boat.length)
                           .by_date_desc
                           .limit(4)
    end

    def set_current_user_boat
      @boat = current_user.boats.find(params[:id])
    end

    def set_current_user_boats
      @boats = current_user.boats.by_date_desc
    end

    def track_view
      return if !ahoy.new_visit? && current_visit

      ahoy.track('listing_show', boat_id: @boat.id)
    end

    def set_payment_notify
      notes = Notifies::Cell::Notifications.new(current_user)
      @payment_notify = notes.set_payment_after_listing_completed
    end

    # Used `ActiveRecord::AssociationRelation#to_a` because otherwise `<<`
    # operator doesn't work. See: https://github.com/rails/rails/issues/25906
    def block_today_booking_if_check_in_expired
      @booking_blockings = @booking_blockings.to_a

      if @boat.classic? && cannot_book_now?(@boat.check_in_time)
        block_today_booking(:classic)
      end

      if @boat.sleepin? && cannot_book_now?(@boat.sleepin_check_in_time)
        block_today_booking(:sleepin)
      end

      if @boat.shared? && cannot_book_now?(@boat.shared_check_in_time)
        block_today_booking(:shared)
      end
    end

    def cannot_book_now?(check_in_time)
      default_check_in_time = '08:00'.to_time
      min_time_before_booking = TravelService::Preference::PRE_BOOKING_MIN_TIME

      Time.now.to_time + min_time_before_booking >
        (check_in_time&.to_s(:time)&.to_time || default_check_in_time)
    end

    def block_today_booking(rental)
      today = Time.zone.today

      @booking_blockings << Travel::BookingBlocking.new(started_at: today,
                                                        finished_at: today,
                                                        rental_type: rental)
    end
  end
end
