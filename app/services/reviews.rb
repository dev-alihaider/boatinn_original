module Reviews
  module_function
  EXPIRATION_DAYS_REVIEW = 14
  EXPIRATION_DAYS_REPLY = 10

  def need_give_review?(travel)
    travel.finished? && !review_done?(travel.current_user, travel.trip)
  end

  def give_review_path(travel)
    if travel.current_user_seller? && travel.shared?
      Rails.application.routes.url_helpers.given_dashboard_reviews_path
    else
      Rails.application.routes.url_helpers.dashboard_review_leave_review_path(
        review_id: Review.given_by(travel.current_user).for_trip(travel.trip).first&.id
      )
    end
  end

  def review_given?(sender, trip)
    Review.given_by(sender).for_trip(trip).given.exists?
  end

  def review_done?(sender, trip)
    Review.received_for(sender).for_trip(trip).where(receiver_review_done: true).exists?
  end

  def pending_for_both_sides?(review)
    review.pending? && !review_given?(review.receiver, review.trip)
  end

  def days_to_expire(review)
    days_after = DateService.duration_in_days(review.created_at, Time.zone.now)
    EXPIRATION_DAYS_REVIEW - days_after + 1
  end

  def rating_blank_for_boat
    {
      count: 0,
      accuracy_avg: 0,
      communication_avg: 0,
      cleanliness_avg: 0,
      location_avg: 0,
      check_in_avg: 0,
      value_avg: 0
    }
  end

  def get_rating_for_boat(boat)
    receiver_id = boat.user_id
    trip_ids = Travel::Trip.select(:id).where(boat_id: boat.id).to_sql
    sql = "
        SELECT
          COUNT(id) AS count,
            ROUND(SUM(accuracy_grade) / COUNT(id), 2) AS accuracy_avg,
            ROUND(SUM(communication_grade) / COUNT(id), 2) AS communication_avg,
            ROUND(SUM(cleanliness_grade) / COUNT(id), 2) AS cleanliness_avg,
            ROUND(SUM(location_grade) / COUNT(id), 2) AS location_avg,
            ROUND(SUM(check_in_grade) / COUNT(id), 2) AS check_in_avg,
            ROUND(SUM(value_grade) / COUNT(id), 2) AS value_avg
            FROM reviews
          WHERE
            target = 0 AND receiver_id = #{receiver_id} AND
            status IN (2,3,4) AND
            receiver_review_done = true AND
            trip_id IN (#{trip_ids}) AND
            enabled = true
    "
    result = ActiveRecord::Base.connection.execute(sql).first.symbolize_keys
    result.each do |key, val|
      result[key] = (key == :count) ? val.to_i : val.to_f
    end
    result
  end


  def statistic_for_boats(boats)
    scope = Review.travel.published.where(trip: Travel::Trip.where(boat: boats)).select("COUNT(id)")
    selects = ["(#{scope.to_sql}) AS reviews_count"]
    (1..5).each do |grade|
      selects << "(#{scope.where(avg_grade: (grade - 0.5)..(grade + 0.49)).to_sql}) AS avg_size_with_grade_#{grade}"
    end
    sql = "SELECT #{selects.join(', ')}"
    avg_sizes = ActiveRecord::Base.connection.execute(sql).first.symbolize_keys

    result = {}
    result[:reviews_count] = avg_sizes[:reviews_count]
    result[:avg_sizes_by_grade] = {}
    avg_sizes.delete(:reviews_count)
    avg_sizes.each do |key, size|
      percents = if size.positive? && result[:reviews_count].positive?
                   (size.to_f / (result[:reviews_count].to_f / 100.0)).round
                   else
                     0
                 end
      result[:avg_sizes_by_grade][(key[-1]).to_i] = {
        size: size,
        percents: percents
      }
    end
    avg_sum = result[:avg_sizes_by_grade].sum{ |grade, r| grade * r[:size] }
    result[:avg_rating] = (result[:reviews_count].positive? ? avg_sum.to_f / result[:reviews_count].to_f : 0).round(2)
    result
  end

end