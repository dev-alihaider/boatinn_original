module MailViewTestData

  def test_email
    'test@email.com'
  end

  def payment
    @payment ||= Travel::Payment.last
  end

  def trip
    @trip ||= Travel::Trip.last
  end

  def client
    @client ||= trip.customers.last.client
  end

  def booking
    @booking ||= Travel::Booking.last
  end

  def credit_card
    @credit_card ||= UserCreditCard.last
  end

  def review
    @review ||= Review.last
  end

  def boat
    @boat ||= Boat.last
  end

  def review_report
    @review_report ||= Report.find_by(reportable_type: 'Review')
  end

  def user_report
    @user_report ||= Report.find_by(reportable_type: 'User')
  end


end