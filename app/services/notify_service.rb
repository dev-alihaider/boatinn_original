module NotifyService
  REMIND_ABOUT_LEAVE_REVIEW = 24.hours
  REMIND_ABOUT_PAYOUT_DETAILS = 24.hours
  REMIND_ABOUT_YOUR_CV = 48.hours

  class << self
    def booking_confirmed_to_seller(booking)
      @recipient = booking.trip.seller
      @note_type = :booking_confirmed_to_seller

      send_email @recipient, @note_type do
        BookingMailer.confirmed_to_seller(booking.id)
      end

      send_sms @recipient, @note_type do
        locals = { reservation_code: booking.reservation_code }
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type, locals)
      end
    end

    def booking_confirmed_to_client(booking)
      @recipient = booking.client
      @note_type = :booking_confirmed_to_client

      send_email @recipient, @note_type do
        BookingMailer.confirmed_to_client(booking.id)
      end

      send_sms @recipient, @note_type do
        locals = { reservation_code: booking.reservation_code }
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type, locals)
      end
    end

    def booking_canceled_by_client_to_seller(booking)
      @recipient = booking.trip.seller
      @note_type = :booking_canceled_by_client_to_seller

      send_email @recipient, @note_type do
        BookingMailer.canceled_by_client_to_seller(booking.id)
      end

      send_sms @recipient, @note_type do
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type)
      end
    end

    def booking_canceled_by_seller_to_client(booking)
      @recipient = booking.client
      @note_type = :booking_canceled_by_seller_to_client

      send_email @recipient, @note_type do
        BookingMailer.canceled_by_seller_to_client(booking.id)
      end

      send_sms @recipient, @note_type do
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type)
      end
    end

    def booking_shared_activated_to_seller(booking)
      @recipient = booking.trip.seller
      @note_type = :booking_shared_activated_to_seller

      send_email @recipient, @note_type do
        BookingMailer.shared_activated_to_seller(booking.id)
      end

      send_sms @recipient, @note_type do
        locals = { reservation_code: booking.reservation_code }
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type, locals)
      end
    end

    def booking_joined_to_seller(booking)
      @recipient = booking.trip.seller
      @note_type = :booking_joined_to_seller

      send_email @recipient, @note_type do
        BookingMailer.joined_to_seller(booking.id)
      end

      send_sms @recipient, @note_type do
        locals = { reservation_code: booking.reservation_code }
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type, locals)
      end
    end

    def booking_joined_to_client(booking)
      @recipient = booking.client
      @note_type = :booking_joined_to_client

      send_email @recipient, @note_type do
        BookingMailer.joined_to_client(booking.id)
      end

      send_sms @recipient, @note_type do
        locals = { reservation_code: booking.reservation_code }
        sms_text_for_booking(booking.client, booking.trip.seller,@note_type, locals)
      end
    end

    def booking_left_to_seller(booking)
      @recipient = booking.trip.seller
      @note_type = :booking_left_to_seller

      send_email @recipient, @note_type do
        BookingMailer.left_to_seller(booking.id)
      end

      send_sms @recipient, @note_type do
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type)
      end
    end

    def cancellation_report_to_client(booking)
      @recipient = booking.client
      @note_type = :cancellation_report_to_client

      send_email @recipient, @note_type do
        BookingMailer.cancellation_report_to_client(booking.id)
      end

      send_sms @recipient, @note_type do
        sms_text_for_booking(booking.client, booking.trip.seller, @note_type)
      end
    end

    def new_unread_message(trip, sender)
      @note_type = :new_unread_message
      travel = ::TravelService::Travel.new(trip, sender)

      # send to customers
      travel.customers.each do |customer|
        send_email customer.client, @note_type do
          BookingMailer.new_unread_message(customer.client_id, trip.id)
        end

        send_sms customer.client, @note_type do
          sms_text_for_booking(customer.client, trip.seller, @note_type)
        end
      end # end each clients

      # send to seller
      if travel.current_user_client?
        send_email trip.seller, @note_type do
          BookingMailer.new_unread_message(trip.seller_id, trip.id)
        end

        send_sms trip.seller, @note_type do
          sms_text_for_booking(nil, trip.seller, @note_type)
        end
      end # end send to boat owner
    end

    def notify_about_insufficient_funds(payment)
      @recipient = payment.booking.client
      @note_type = :notify_about_insufficient_funds

      send_email @recipient, @note_type do
        PaymentMailer.notify_about_insufficient_funds(payment)
      end

      send_sms @recipient, @note_type do
        sms_text_for_booking(payment.booking.client, payment.booking.trip.seller, @note_type)
      end
    end

    def credit_card_added(card)
      @recipient = card.user
      @note_type = :credit_card_added

      send_email @recipient, @note_type do
        PaymentMailer.credit_card_added(card)
      end
    end

    def client_should_leave_review(trip, client)
      @recipient = client
      @note_type = :client_should_leave_review

      send_email @recipient, @note_type do
        ReviewMailer.client_should_leave_review(trip, client)
      end
    end

    def boat_owner_has_left_review(review)
      @recipient = review.receiver
      @note_type = :boat_owner_has_left_review

      send_email @recipient, @note_type do
        ReviewMailer.boat_owner_has_left_review(review)
      end
    end

    def read_boat_owner_review(review)
      @recipient = review.receiver
      @note_type = :read_boat_owner_review

      send_email @recipient, @note_type do
        ReviewMailer.read_boat_owner_review(review)
      end
    end

    def boat_owner_should_leave_review(trip)
      @recipient = trip.seller
      @note_type = :boat_owner_should_leave_review

      send_email @recipient, @note_type do
        ReviewMailer.boat_owner_should_leave_review(trip)
      end
    end

    def client_has_left_review(review)
      @recipient = review.receiver
      @note_type = :client_has_left_review

      send_email @recipient, @note_type do
        ReviewMailer.client_has_left_review(review)
      end
    end

    def read_client_review(review)
      @recipient = review.receiver
      @note_type = :read_client_review

      send_email @recipient, @note_type do
        ReviewMailer.read_client_review(review)
      end
    end

    def boat_finished_without_payment(boat)
      @recipient = boat.user
      @note_type = :boat_finished_without_payment

      send_email @recipient, @note_type do
        ListingMailer.boat_finished_without_payment(boat)
      end
    end

    def boat_finished_without_cv(boat)
      @recipient = boat.user
      @note_type = :boat_finished_without_cv

      send_email @recipient, @note_type do
        ListingMailer.boat_finished_without_cv(boat)
      end
    end

    def boat_image_updated(boat)
      @recipient = boat.user
      @note_type = :boat_image_updated

      send_email @recipient, @note_type do
        ListingMailer.boat_image_updated(boat)
      end
    end

    def listing_offlined(boat)
      @recipient = boat.user
      @note_type = :listing_offlined

      send_email @recipient, @note_type do
        ListingMailer.boat_offlined(boat)
      end
    end

    def owner_got_earnings(payment)
      @recipient = payment.booking.trip.seller
      @note_type = :owner_got_earnings

      send_email @recipient, @note_type do
        PaymentMailer.owner_got_earnings(payment)
      end
    end

    def boat_not_completed(boat)
      @recipient = boat.user
      @note_type = :boat_not_completed

      send_email @recipient, @note_type do
        ListingMailer.boat_not_completed(boat)
      end
    end

    def welcome_to_service(user)
      @recipient = user
      @note_type = :welcome_to_service

      send_email @recipient, @note_type do
        UserMailer.welcome_email(@recipient)
      end
    end

    def user_banned(user)
      @recipient = user
      @note_type = :user_banned

      send_email @recipient, @note_type do
        UserMailer.user_banned(@recipient)
      end
    end

    def phone_number_deleted(user, phone_number)
      @recipient = user
      @note_type = :phone_number_deleted

      send_email @recipient, @note_type do
        UserMailer.phone_number_deleted(@recipient, phone_number)
      end
    end

    def phone_number_updated(user, old_phone_number)
      @recipient = user
      @note_type = :phone_number_updated

      send_email @recipient, @note_type do
        UserMailer.phone_number_updated(@recipient, old_phone_number)
      end
    end

    def ask_think_about_boat(boat, user)
      @recipient = user
      @note_type = :ask_think_about_boat

      send_email @recipient, @note_type do
        UserMailer.ask_think_about_boat(boat, @recipient)
      end
    end

    def password_changed(user)
      @recipient = user
      @note_type = :password_changed

      send_email @recipient, @note_type do
        UserMailer.password_changed(@recipient)
      end
    end

    private

    def sms_text_for_booking(client, seller, event, locals = {})
      locals.merge!(
        host: ActionMailer::Base.default_url_options[:host],
        client_name: client&.display_name,
        seller_name: seller.display_name
      )
      base_message = I18n.t("sms.#{event}", locals)
      caption = I18n.t("sms.caption", locals)
      "#{base_message}\n#{caption}"
    end

    def send_email(recipient, note_type, &block)
      (block.call).deliver_now if recipient.should_receive_email?(note_type.to_s.to_sym)
    end

    def send_sms(recipient, note_type, &block)
      SendSmsJob.perform_now(recipient.id, block.call) if recipient.should_receive_sms?(note_type)
    end

  end

end
