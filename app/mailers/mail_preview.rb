class MailPreview < MailView
  include MailViewTestData

  def e11__canceled_by_seller_to_client
    BookingMailer.canceled_by_seller_to_client(booking.id)
  end

  def e12__cancellation_report_to_client
    BookingMailer.cancellation_report_to_client(booking.id)
  end

  def e13__notify_about_insufficient_funds
    PaymentMailer.notify_about_insufficient_funds(payment)
  end

  def e14__credit_card_added
    PaymentMailer.credit_card_added(credit_card)
  end

  def e15__booking_joined_to_client
    BookingMailer.joined_to_client(booking.id)
  end

  def e16__booking_requested_to_client
    BookingMailer.confirmed_to_client(booking.id)
  end

  def e17__client_should_leave_review
    ReviewMailer.client_should_leave_review(trip, client)
  end

  def e18__boat_owner_has_left_review
    ReviewMailer.boat_owner_has_left_review(review)
  end

  def e19__read_boat_owner_review
    ReviewMailer.read_boat_owner_review(review)
  end

  def e21__boat_finished_without_payment
    ListingMailer.boat_finished_without_payment(boat)
  end

  def e22__boat_finished_without_cv
    ListingMailer.boat_finished_without_cv(boat)
  end

  def e23__booking_requested_to_owner
    BookingMailer.confirmed_to_seller(booking.id)
  end

  def e24__shared_activated_to_seller
    BookingMailer.shared_activated_to_seller(booking.id)
  end

  def e25__booking_joined_to_seller
    BookingMailer.joined_to_seller(booking.id)
  end

  def e26__boatshared_left_to_seller
    BookingMailer.left_to_seller(booking.id)
  end

  def e27__canceled_by_client_to_owner
    BookingMailer.canceled_by_client_to_seller(booking.id)
  end

  def e28__boat_offlined
    ListingMailer.boat_offlined(boat)
  end

  def e29__boat_image_updated
    ListingMailer.boat_image_updated(boat)
  end

  def e210_owner_got_earnings
    PaymentMailer.owner_got_earnings(payment)
  end

  def e211_boat_not_completed
    ListingMailer.boat_not_completed(boat)
  end

  def e212_boat_owner_should_leave_review
    ReviewMailer.boat_owner_should_leave_review(trip)
  end

  def e213_client_has_left_review
    ReviewMailer.client_has_left_review(review)
  end

  def e214_read_client_review
    ReviewMailer.read_client_review(review)
  end

  def e31__confirmation_email
    Devise::Mailer.confirmation_instructions(client, 'test_token')
  end

  def e32__welcome_email
    UserMailer.welcome_email(client)
  end

  def e33__share_booking
    BookingMailer.share_booking(test_email, booking.id)
  end

  def e34__user_banned
    UserMailer.user_banned(client)
  end

  def e35__phone_number_deleted
    UserMailer.phone_number_deleted(client, '+00000000000000')
  end

  def e36__password_changed
    UserMailer.password_changed(client)
  end

  def e37__phone_number_updated
    UserMailer.phone_number_updated(client, '+00000000000000')
  end

  def e38__new_unread_message
    BookingMailer.new_unread_message(client.id, trip.id)
  end

  def e39__ask_think_about_boat
    UserMailer.ask_think_about_boat(boat, client)
  end

  def e310_reset_password
    Devise::Mailer.reset_password_instructions(client, 'test-token')
  end

  def notify_admins_about_review_report
    AdminMailer.notify_admins_about_review_report(review_report)
  end

  def notify_admins_about_user_report
    AdminMailer.notify_admins_about_user_report(user_report)
  end


end

