module Travel

  class CreateMessageToOwner < ::Trailblazer::Operation

    step :export_travel_from_skill
    step :set_travel_status!
    step :payments_to_initiated!
    step :sets_reservation_code!
    step :write_travel_to_db!
    step :send_message_from_current_user!

    def export_travel_from_skill(skill, **)
      @travel = skill[:travel]
    end

    def set_travel_status!(_skill, **)
      @travel.trip.status = :free
    end

    def payments_to_initiated!(_skill, **)
      @travel.payments.each do |payment|
        payment.status = :initiated
        payment.type_of = :prime
        payment.plan_charge_at = nil
      end
    end

    def sets_reservation_code!(_skill, **)
      @travel.current_bookings.each do |booking|
        if booking.reservation_code.blank?
          booking.reservation_code = TravelService::Trip::PREFERENCE.generate_reservation_code
        end
      end
    end

    def write_travel_to_db!(_skill, **)
      [
        @travel.trip.save!,
        @travel.current_bookings.all?(&:save!),
        @travel.current_customer.save!,
        @travel.payments.all?(&:save!)
      ]
    end

    def generate_invoices!(_skill, **)
      @travel.current_bookings.each do |booking|
        ::Travel::Invoice.generate_new_numbers(booking.id)
      end
    end

    def send_message_from_current_user!(skill, **)
      return true if skill[:message].blank?

      attributes = {
        sender: @travel.current_user,
        content: skill[:message]
      }
      message = @travel.trip.messages.create(attributes)

      ::TravelService::Transition.message_added(@travel, message)
    end
  end
end

