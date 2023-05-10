module TravelService::Trip
  module_function
  PREFERENCE = TravelService::Preference

  def create_initiated_travel!(travel, source)
    return Result::Error.new(:missing_payment) if source.blank? || !source.to_s.start_with?('pm_')

    # sets reservation code, before save booking
    travel.current_bookings.each do |book|
      if book.reservation_code.blank?
        book.reservation_code = PREFERENCE.generate_reservation_code
      end
    end

    # save all data - trip, booking, payments, customer
    travel.payments.each{ |p| p.source = source }
    data_saved = [
      travel.trip.save!,
      travel.current_bookings.all?(&:save!),
      travel.current_customer.save!,
      travel.payments.all?(&:save!)
    ].all?

    unless data_saved
      travel.trip.destroy
      return Result::Error.new(:data)
    end

    travel.payments.each do |p|
      p.source = source
    end

    # stripe pay process
    payments_for_pay = travel.payments.select{ |p| p.plan_charge_at.blank? }
    paid_result = pay_payments!(travel.current_user, payments_for_pay)
    if paid_result.failure?
      travel.trip.destroy
      return paid_result
    end

    Result::Success.new(travel)
  end


  # after paid, or when paid now is skipped
  def confirm_travel!(travel, client_first_message)
    payments_for_defer = travel.payments.select{ |p| p.plan_charge_at.present? }
    travel.trip.update(status: :accepted)

    # wil be paid later
    defer_payments!(payments_for_defer)

    # merge trips and customers if rental type shared
    main_trip = travel.shared? ? find_trip_for(travel.trip.boat_id, travel.check_in, travel.trip.id) : nil

    if main_trip.present?
      merge_travels(travel, main_trip)
      ::TravelService::Transition.joined_to_trip(travel)
    elsif travel.shared?
      ::TravelService::Transition.shared_activated(travel)
    else
      ::TravelService::Transition.reservation_confirmed(travel)
    end

    # build invoices
    travel.current_bookings.each do |booking|
      ::Travel::Invoice.generate_new_numbers(booking.id)
    end

    # send message
    if client_first_message.present?
      travel.trip.messages.create(
        sender: travel.current_user,
        content: client_first_message
      )
    end

    if main_trip.blank?
      Travel::TripCreatedJob.perform_later(travel.trip.id)
    end
    Result::Success.new(travel)
  rescue
    Result::Error.new(travel)
  end

  def pay_payments!(payer, payments)
    return Result::Success.new('payments do not exists') if payments.blank?

    result = Result::Error.new(:payment)
    # pay payments
    payments.each do |payment|
      # result = PaymentService.charge(payer, payment, capture: false)
      result = StripeApi.intentize_payment!(payment, capture: false, offline: false)
      break unless result[:success]
    end

    result[:success] ? result : Result::Error.new(:payment)
  end

  def defer_payments!(payments)
    return if payments.blank?

    # pay later job
    payments.each do |payment|
      PaymentChargeJob.set(wait_until: payment.plan_charge_at).perform_later(payment.id)
    end
  end

  def merge_travels(travel, main_trip)
    merge_trips!(main_trip, travel.trip)
    main_customer = main_trip.customers.find_by(client: travel.current_user)
    if main_customer.present?
      merge_customers!(main_customer, travel.current_customer, main_trip.rental)
    else
      travel.current_customer.update(trip_id: main_trip.id)
    end
    travel.current_bookings.each{ |b| b.update(trip: main_trip) }
    travel.trip.reload.destroy
    travel.attach_trip(main_trip)
  end

  def merge_trips!(main_trip, sub_trip)
    main_trip.client_fee       += sub_trip.client_fee
    main_trip.seller_fee       += sub_trip.seller_fee
    main_trip.service_fee      += sub_trip.service_fee
    main_trip.earnings         += sub_trip.earnings
    main_trip.subtotal         += sub_trip.subtotal
    main_trip.total            += sub_trip.total
    main_trip.number_of_guests += sub_trip.number_of_guests
    main_trip.number_of_period += sub_trip.number_of_period unless main_trip.shared?

    main_trip.per_price =
      if main_trip.shared?
        main_trip.subtotal / main_trip.number_of_guests
      else
        main_trip.subtotal / main_trip.number_of_period
      end
    main_trip.save!
  end

  def merge_customers!(main_customer, sub_customer, rental)
    rental = rental.to_sym
    main_customer.client_fee       += sub_customer.client_fee
    main_customer.seller_fee       += sub_customer.seller_fee
    main_customer.service_fee      += sub_customer.service_fee
    main_customer.earnings         += sub_customer.earnings
    main_customer.subtotal         += sub_customer.subtotal
    main_customer.total            += sub_customer.total
    main_customer.number_of_guests += sub_customer.number_of_guests
    main_customer.number_of_period += sub_customer.number_of_period unless rental == :shared

    main_customer.per_price =
      if rental == :shared
        main_customer.subtotal / main_customer.number_of_guests
      else
        main_customer.subtotal / main_customer.number_of_period
      end
    main_customer.save!
  end

  def number_of_guests_for(boat_id:, date:)
    find_trip_for(boat_id, date)&.number_of_guests || 0
  end

  def find_trip_for(boat_id, date, except_trip_id = nil)
    ::Travel::Trip.where(
      boat_id: boat_id,
      check_in: date,
      status: :accepted
    ).where.not(id: except_trip_id).first
  end

  def reset_autoincrements!
    Travel::Trip.reset_autoincrement!
    Travel::Customer.reset_autoincrement!
  end

end
