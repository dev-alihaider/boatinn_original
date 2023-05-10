class Travel::CancelTrip < Trailblazer::Operation
  extend Contract::DSL

  contract do
    property :trip
    property :subject
    property :reason
    property :seller
    property :refunded_cents
    property :penalty_cents
    property :currency
    property :canceler_id
  end

  step Model(Travel::TripCancellation, :new)
  step :ensure_trip_and_canceller
  step :ident_travel
  step :ident_seller
  step :ident_refund_type
  step :calculate_refund_amount
  step :set_penalty
  step :cancel_bookings!
  step :assign_penalty_to_canceller!
  step Contract::Build()
  step Contract::Validate()
  step Contract::Persist()
  step :send_transition

  private

  def ensure_trip_and_canceller(skill, **)
    return fail(:canceller_not_set) if skill[:params][:canceller].blank?
    return fail(:trip_not_set)      if skill[:params][:trip].blank?

    @canceller = skill[:params][:canceller]
    @trip      = skill[:params][:trip]
  end

  def ident_travel(skill, *)
    @travel = TravelService::Travel.new(@trip, @canceller)
    @travel.can_cancel? ? true : fail('travel can`t be canceled')
    skill[:params][:canceler_id] = @canceller.id
  end

  def ident_seller(skill, **)
    skill[:params][:seller] = @travel.current_user_seller?
    true
  end

  def ident_refund_type(skill, **)
    @refund_type = skill[:params][:seller] ? :all : :cancellation_policy
  end

  def calculate_refund_amount(skill, **)
    amount = TravelService::Cancellation.will_refund_from_travel(@travel)
    skill[:params][:refunded_cents] = amount.cents
    skill[:params][:currency] = amount.currency
  end

  def set_penalty(skill, **)
    skill[:params][:penalty_cents] =
      if @travel.current_user_seller?
        current_seller_cancellations = @canceller&.penalization&.current_cancellations || 0
        penalty_sizes = TravelService::Preference::PENALIZATION_TIMES_SIZE_CENTS
        penalty_sizes[current_seller_cancellations] || penalty_sizes.last
      else
        0
      end
    true
  end

  def cancel_bookings!(skill, opts)
    @travel.current_bookings.each do |booking|
      cancel_params = { booking: booking, refund_type: @refund_type }
      sub_result = Travel::CancelBooking.(params: cancel_params)
      return fail("can`t cancel booking - #{bookinh.id}") if sub_result.failure?
    end
    opts['params'] = skill[:params]
  end

  def assign_penalty_to_canceller!(skill, **)
    return true unless skill[:params][:seller]
    penalty = Money.new(skill[:params][:penalty_cents], skill[:params][:currency])
    Penalization::AddPenalty.(params: { user: @canceller, amount: penalty })
  end

  def send_transition(skill, **)
    TravelService::Transition.travel_canceled(@travel, skill[:params][:reason])
    true
  end

end
