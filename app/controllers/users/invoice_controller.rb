# frozen_string_literal: true

module Users
  class InvoiceController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :ensure_booking_and_member

    def show
      if current_user.id == @booking.client_id
        @service_fee = @booking.client_fee
        @invoice_number = @booking.invoice.client_number
      else
        if params[:for_penalty] == 'true'
          @booking = cancelled_booking
          if @booking.blank?
            flash[:error] = t('invoice.not_exists')
            redirect_back(fallback_location: dashboard_earnings_path) and return
          end
          @service_fee = Money.new(0, @booking.currency)
          @vat_fee = Money.new(0, @booking.currency)
        end

        @service_fee ||= @booking.seller_fee
        @invoice_number = @booking.invoice.seller_number
      end
      @vat_decode ||= "1.#{@booking.trip.vat_fee_percents}"
      @vat_cal ||= @vat_decode.to_f
      @vat_fee ||= @service_fee - (@service_fee / @vat_cal)

      respond_to do |format|
        format.html do
          render 'show'
        end
        format.pdf do
          render pdf: 'invoice', template: 'users/invoice/invoice.pdf'
        end
      end
    end

    private

    def ensure_booking_and_member
      @booking = Travel::Booking.find_by(id: params[:booking_id])
      unless @booking.present?
        flash[:error] = t("notices.booking_not_found")
        return redirect_back(fallback_location: root_path)
      end

      unless [@booking.trip.seller_id, @booking.client_id].include?(current_user.id)
        flash[:error] = t("notices.permission_denied")
        return redirect_back(fallback_location: root_path)
      end
      @member = current_user
    end

    def cancelled_booking
      cancellation = Travel::TripCancellation
                       .where(payment_penalty_excision_id: @booking.payments.ids)
                       .first
      return nil if cancellation.blank?
      cancellation.trip.bookings.first
    end

  end
end
