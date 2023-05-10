# frozen_string_literal: true
# this controller is deprecated and not usable
# recommend to destroy, service switched stripe express account
module Users
  class AccountController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :possible_cancel_account, only: %[cancel_account]

    def index
      redirect_to notifications_dashboard_account_index_path
    end

    def cancel_account
      update_settings
      current_user.update_attributes!(closed: true)
      close_current_user_boats
      sign_out
      flash[:success] = t('account_canceled')
      redirect_to root_path
    end

    def notifications
      @user_notifications = current_user.settings(:notifications)
      @user_notifications.sms = true if @user_notifications.sms.nil?
      @user_notifications.email = true if @user_notifications.email.nil?
    end

    def update_notifications
      User.notifications.each_key do |key|
        current_user.settings(:notifications).update_attributes! attribute(key)
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to notifications_dashboard_account_index_path
    end

    def payment
      @cards = StripeApi.user_payment_methods(current_user).payload
      @removable = @cards.count > 1
    end

    def penalization
      @penalization = current_user.penalization
      unless @penalization.present?
        flash[:error] = t('notices.you_have_not_penalization_account')
        redirect_to root_path and return
      end
      @trips = Penalization.canceled_trips_by_seller(current_user)
    end

    private

    def possible_cancel_account
      have_open_trips = [
          Travel::Trip.accepted.where(seller: current_user).exists?,
          Travel::Trip.accepted.joins(:customers).where(travel_customers: { client_id: current_user.id } ).exists?
      ].any?

      return unless have_open_trips

      flash[:error] = t('you_need_close_trips')
      redirect_back(fallback_location: root_path)
    end

    def update_settings
      hash = { reason: params[:notifications],
               reason_other_text: params[:reason_other_text],
               can_contact: params[:can_contact] }
      current_user.settings(:cancel_reasons).update_attributes!(hash)
    end

    def attribute(key)
      { key => params[:notifications].try(:[], key).present? }
    end

    def close_current_user_boats
      current_user.boats.update_all(
        classic: false,
        sleepin: false,
        shared: false
      )
    end

  end
end
