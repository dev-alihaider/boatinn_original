module StatisticService

  class << self
    def views_boats_by_month(boat_ids, month_date)
      start_at = month_date.beginning_of_month
      end_at   = month_date.end_of_month

      travel_scope = Travel::Trip.joins(:bookings)
                       .where(boat_id: boat_ids, check_in: start_at..end_at)
      ahoy_scope = Ahoy::Event
                     .where("properties ->> 'boat_id' IN (?)", boat_ids.map(&:to_s))
                     .where(time: start_at..end_at)

      status_open = Travel::Booking.statuses["open"]

      {
        views_count: ahoy_scope.count,
        request_count: travel_scope.count,
        reservation_count: travel_scope.approved.where(travel_bookings: { status: status_open } ).count,
        month: month_date
      }
    end
  end
end
