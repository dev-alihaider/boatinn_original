# frozen_string_literal: true

class WizardsController < GeneralUsersController # :nodoc:
  before_action :authenticate_user!
  before_action :set_current_user_boat, only: %i[edit update]

  def index
    redirect_to dashboard_listings_path
  end

  def new
    @boat = Boat.new
    @non_experience = Category.non_experience.all
    @experience = Category.experience.all
    @target_stage = set_required_stage
    build
  end

  def edit
    maybe_redirect_to_import

    # Set referer.
    session[:referer] = request.referer

    # Fix empty page for finished wizard.
    if listing_finished? && params[:stage].blank? && flash[:error].blank?
      redirect_to edit_dashboard_listing_path(@boat)
    end

    @non_experience = Category.non_experience.all
    @experience = Category.experience.all
    @boat.build_location if @boat.location.blank?
    @boat.season_rates.build if @boat.season_rates.empty?
    @target_stage = set_required_stage

    # Availability calendar data for boat to reduce AJAX requests by 1.
    @booking_blockings =
      @boat.booking_blockings.within_dates(current_user.calendar_started_at,
                                           current_user.calendar_finished_at)
           .with_rental_type(:classic).order_by_started_at
    @bookings = @boat.bookings.opened.classic
                     .within_dates(current_user.calendar_started_at,
                                   current_user.calendar_finished_at)
  end

  def show
    redirect_to edit_wizard_path(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      @boat = Boat.new(params['boat'].permit!)
      @boat.user = current_user

      begin
        @boat.save!
        ListingCreatedJob.perform_later(@boat.id)
      rescue StandardError => error
        flash[:error] = error.message
        render :new
      else
        if params[:save_and_exit].present? && params[:save_and_exit] == 'true'
          redirect_to wizards_path
        else
          redirect_to edit_wizard_path(@boat)
        end
      end
    end
  end

  def update
    prev_state_finished = @boat.finished?
    boat_params = params['boat'].permit!
    boat_params = boat_params.except(:wizard_progress) if listing_finished?
    boat_params = delete_empty_season_rates(boat_params)

    update_user_image
    update_boat_booking_blockings

    @boat.update!(boat_params)
    just_finished = !prev_state_finished && @boat.finished?
    ListingUpdatedJob.perform_later(@boat.id, just_finished)
  rescue StandardError => error
    # To discard success messages and correct display errors.
    flash.discard
    flash[:error] = error.message
    redirect_to request.referer
  else
    # Use referer to choose redirect to.
    redirect_path = if session[:referer] == edit_dashboard_listing_url(@boat)
                      if params[:save_and_exit].presence == 'true'
                        edit_dashboard_listing_path(@boat)
                      else
                        edit_wizard_path(@boat)
                      end
                    elsif session[:referer] == dashboard_listings_url ||
                          listing_finished? ||
                          params[:save_and_exit].presence == 'true'
                      dashboard_listings_path
                    else edit_wizard_path(@boat)
                    end

    # Unset referer.
    session[:referer] = nil

    redirect_to redirect_path
  end

  ##
  # Work algorithm, redirects chain:
  #
  # [Not authorized in Facebook]
  #   [WizardsController]
  #   => #import_facebook_picture => #authenticate_facebook =>
  #      /users/auth/facebook =>
  #
  #   [OmniauthCallbacksController]
  #   => /users/auth/facebook => /users/auth/facebook/callback =>
  #      WizardsController#edit =>
  #
  # [Authorized in Facebook]
  #   [WizardsController]
  #   => #edit => #import_facebook_picture
  def import_facebook_picture
    return authenticate_facebook unless current_user.auth_via == 'facebook'

    download_facebook_image(params[:wizard_id])
    redirect_to edit_wizard_path(params[:wizard_id])
  end

  private

  def set_current_user_boat
    @boat = current_user.boats.find(params[:id])
  end

  def delete_empty_season_rates(boat_params)
    if boat_params[:season_rates_attributes].present?
      boat_params[:season_rates_attributes].delete_if do |_id, season_rate|
        !season_rate_valid?(season_rate)
      end
    end
    boat_params
  end

  def season_rate_valid?(season_rate)
    season_rate[:offer_name].present? &&
      season_rate[:started_at].present? &&
      season_rate[:finished_at].present? &&
      (season_rate[:per_half_day].present? || season_rate[:per_day].present? ||
      season_rate[:per_night].present? || season_rate[:per_week].present?)
  end

  def build
    @boat.build_location
    @boat.user = current_user
    @boat.wizard_progress = 1
    @boat.features.build
  end

  # TODO: Move `params[:user][:image]` -> `params[:boat]` and default updating
  def update_user_image
    return unless params.key?(:user) && params[:user].key?(:image)

    current_user.create_image if current_user.image.blank?

    if current_user.image.update(attachment: params[:user][:image])
      flash[:success] = t('wizards.index.page09.successfully_uploaded_profile_image')
    else
      flash[:error] = t('wizards.index.page09.failure_uploading_profile_image')
    end
  end

  def update_boat_booking_blockings
    return unless params.key?(:calendars) && params[:calendars].present?

    # TODO: Add code for converting dates_string => date_ranges
    # (started_at, finished_at) and correct saving dates in DB
    # 2018-03-02,,2018-02-26,2018-02-27,2018-02-28,2018-02-27,,,,,
    # => ["2018-02-26", "2018-02-27", "2018-02-28", "2018-03-02"]
    dates_array = params[:calendars].split(',').reject(&:blank?).sort.uniq
    dates_hash = dates_array.map do |date_string|
      date = Date.parse(date_string)
      { started_at: date, finished_at: date }
    end
    @boat.booking_blockings.create!(dates_hash)
  end

  def authenticate_facebook
    session[:should_redirected_to_import_facebook_picture] = true
    redirect_to user_facebook_omniauth_authorize_path
  end

  ##
  # Redirect => #import_facebook_picture if Facebook authenticated but picture
  # not imported yet.
  def maybe_redirect_to_import
    return unless session[:should_redirected_to_import_facebook_picture]

    session[:should_redirected_to_import_facebook_picture] = false
    redirect_to wizard_import_facebook_picture_path(params[:id])
  end

  ##
  # NOTE: Synchronous way, for excellent user experience.
  #   current_user.image.download_remote_attachment(current_user
  #                                                   .image_url_facebook)
  #
  # NOTE: Asynchronous way for AJAX. WARNING: Sidekiq must be started.
  #   DownloadRemoteUserImageJob.perform_later(current_user.image,
  #                                            current_user.image_url_facebook)
  def download_facebook_image(boat_id)
    return if session[:is_facebook_picture_imported] ||
              current_user.image_url_facebook.blank?

    current_user.create_image if current_user.image.blank?
    current_user&.image&.download_remote_attachment(current_user
      .image_url_facebook)

    return unless current_user&.image&.attachment&.exists?

    @boat = Boat.find(boat_id)
    @boat.update(wizard_progress: 9) unless listing_finished?

    # Store import status between requests. Used in view to hide `Use Facebook
    # image` button link.
    session[:is_facebook_picture_imported] = true
    flash[:notice] = t('wizards.index.page09.successfully_imported_facebook_picture')
  end

  def set_required_stage
    params[:stage].present? ? params[:stage].to_i : @boat.wizard_progress
  end

  def listing_finished?
    @boat.wizard_progress == ListingsHelper::WIZARD_TOTAL_STEPS
  end
end
