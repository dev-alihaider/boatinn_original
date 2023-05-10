module TravelService::Transition
  class << self

    def joined_to_trip(travel)
      create_transition_message(travel, :joined)
      travel.current_bookings.each do |booking|
        job(:joined_to_trip).perform_later(booking.id)
      end
    end

    def shared_activated(travel)
      create_transition_message(travel, :joined)
      travel.current_bookings.each do |booking|
        job(:shared_activated).perform_later(booking.id)
      end
    end

    def reservation_confirmed(travel)
      create_transition_message(travel, :reserved)
      travel.current_bookings.each do |booking|
        job(:reservation_confirmed).perform_later(booking.id)
      end
    end

    def message_added(travel, new_message)
      travel.trip.touch
      job(:message_created).perform_later(new_message.id)
    end

    def travel_canceled(travel, reason)
      if reason.present?
        travel.trip.messages.create(
          sender: travel.current_user,
          content: reason
        )
      end
      create_transition_message(travel, :canceled)
      if travel.current_user_seller?
        travel.trip.decline!
      elsif travel.customers.count.zero?
        travel.trip.update(status: :aborted)
      end

      travel.trip.update(
        number_of_guests: travel.trip.bookings.open.sum(:number_of_guests)
      )

      if travel.shared? && travel.current_customer.present?
        # kick user from conversation
        travel.current_customer.update(left_at: Time.zone.now)
      end
      job(:trip_canceled).perform_later(travel.trip.id, travel.current_user.id)
    end

    def create_transition_message(travel, transition)
      travel.trip.messages.create(
        sender: travel.current_user,
        context: :transition,
        content: transition,
        metadata: {
          number_of_guests: travel.number_of_guests
        }
      )
    end

    private

    def job(job_name)
      klass = job_name.to_s.split('_').map{ |s| s.capitalize }.join('')
      job_class = "::Travel::#{klass}Job".constantize
      job_class.set(wait_until: 1.minute.from_now)
    end

  end
end
