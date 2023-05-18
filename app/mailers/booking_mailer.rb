class BookingMailer < ApplicationMailer
  add_template_helper(ListingsHelper)

  def share_booking(email_recipient, booking_id)
    booking_locals booking_id do
      rental = @trip.shared? ? 'boatShare' : ''
      @locals.merge!(rental_type: rental)
    end

    mail(to: email_recipient, subject: @subject)
  end

  def confirmed_to_seller(booking_id)
    booking_locals booking_id
    @travel = TravelService::Travel.new(@trip, @seller)
    @travel.attach_current_bookings([@booking])
    @message_text = @travel.messages.messages.where(sender: @client).last&.content
    user_email @seller do |email|
      mail(to: email, bcc: "info@boatinn.es", subject: @subject)
    end
  end

  def confirmed_to_client(booking_id)
    booking_locals booking_id
    @travel = TravelService::Travel.new(@trip, @client)
    @travel.attach_current_bookings([@booking])
    user_email @booking.client do |email|
      mail(to: email, bcc: "info@boatinn.es", subject: @subject)
    end
  end

  def canceled_by_client_to_seller(booking_id)
    booking_locals booking_id
    @reason = @booking.trip.trip_cancellation.reason
    user_email @seller do |email|
      mail(to: email, bcc: "info@boatinn.es", subject: @subject)
    end
  end

  def canceled_by_seller_to_client(booking_id)
    booking_locals booking_id
    location = @booking.trip.boat_hash[:location]
    search_params = { location: {
      name: location[:name],
      lat: location[:lat],
      lng: location[:lng]
    }, locale: I18n.locale }
    @similar_listings_url = search_url(search_params)
    user_email @booking.client do |email|
      mail(to: email, bcc: "info@boatinn.es", subject: @subject)
    end
  end

  def shared_activated_to_seller(booking_id)
    booking_locals booking_id
    @travel = TravelService::Travel.new(@trip, @seller)
    @travel.attach_current_bookings([@booking])
    @message_text = @travel.messages.messages.where(sender: @client).last&.content
    user_email @seller do |email|
      mail(to: email, bcc: "info@boatinn.es", subject: @subject)
    end
  end

  def joined_to_seller(booking_id)
    booking_locals booking_id
    @travel = TravelService::Travel.new(@trip.reload, @seller)
    @travel.attach_current_bookings([@booking])
    @message_text = @travel.messages.messages.where(sender: @client).last&.content
    user_email @seller do |email|
      mail(to: email, subject: @subject)
    end
  end

  def joined_to_client(booking_id)
    booking_locals booking_id
    @travel = TravelService::Travel.new(@trip, @client)
    @travel.attach_current_bookings([@booking])
    user_email @booking.client do |email|
      mail(to: email, subject: @subject)
    end
  end

  def left_to_seller(booking_id)
    booking_locals booking_id
    @reason = @booking.trip.trip_cancellation.reason
    user_email @seller do |email|
      mail(to: email, subject: @subject)
    end
  end

  def cancellation_report_to_client(booking_id)
    booking_locals(booking_id)
    @refund_amount = @booking.trip.trip_cancellation&.refunded || 0
    @source_name = @booking.payments.first.source || @booking.client.current_credit_card&.brand
    @refund_amount = Money.new(0, @booking.currency) if @refund_amount.zero?
    user_email @booking.client do |email|
      mail(to: email, subject: @subject)
    end
  end

  def new_unread_message(recipient_id, trip_id)
    @trip = ::Travel::Trip.find(trip_id)
    @recipient = User.find(recipient_id)
    user_email @recipient do
      mail(
        to: @recipient.email,
        bcc: "info@boatinn.es",
        subject: t("booking_mailer.new_unread_message.subject")
      )
    end
  end

  private

  def booking_locals(booking_or_booking_id)
    @booking = booking_or_booking_id.is_a?(Integer) ? Travel::Booking.find(booking_or_booking_id) : booking_or_booking_id
    @trip    = @booking.trip
    @seller  = @trip.seller
    @client  = @booking.client

    @locals = {
      seller_name: @seller.display_name,
      client_name: @client.display_name,
      address: @booking.trip.boat_hash[:location][:address],
      service_name: I18n.t('service_name')
    }

    yield if block_given?

    # set subject by called method
    mailer_method_key = caller_locations(1, 1)[0].label
    @subject = I18n.t("booking_mailer.#{mailer_method_key}.subject", @locals)
  end

end
