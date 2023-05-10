module TripQueryService
  module_function

  def unread_seller_events_size(seller)
    query(@unread_seller_events_size_sql, seller_id: seller.id).first["sum"].to_i
  end

  def unread_messages_size(user)
    query(@unread_messages_size_sql, user_id: user.id).first["sum"].to_i
  end

  def unread_messages(user)
    message_ids = @unread_messages_ids_sql.call(user_id: user.id)
    Travel::Message.where("id IN (#{message_ids})").order(created_at: :desc)
  end

  def unread_seller_events(user)
    events_ids = @unread_seller_events_ids_sql.call(user_id: user.id)
    Travel::Message.where("id IN (#{events_ids})").order(created_at: :desc)
  end

  def query(sql, values)
    ActiveRecord::Base.connection.execute(sql.call(values))
  end

  # params hash
  # - seller_id
  @unread_seller_events_size_sql = ->(params) {
    "
      SELECT SUM((
          SELECT COUNT(id)
          FROM travel_messages
          WHERE
            (
              trip_id = travel_trips.id
            ) AND
            (
              context = #{Travel::Message.contexts['transition']}
            ) AND
            (
              created_at > travel_trips.seller_seen_at
            )
      ))
      FROM travel_trips
      WHERE
        (
          travel_trips.updated_at > travel_trips.seller_seen_at
        ) AND
        (
          travel_trips.seller_id = #{params[:seller_id]}
        )
    "
  }

  # params hash
  # - user_id
  @unread_messages_size_sql = ->(params) {
    "
      SELECT SUM((
          SELECT COUNT(id)
          FROM travel_messages
          WHERE
            (
              trip_id = travel_trips.id AND
              context = #{Travel::Message.contexts['message']}
            ) AND
            (
              (
                travel_customers.id IS NULL AND travel_messages.created_at > travel_trips.seller_seen_at
              ) OR
              (
                travel_customers.id IS NOT NULL AND travel_messages.created_at > travel_customers.seen_at
              )
            )
          ))
      FROM travel_trips
      LEFT OUTER JOIN travel_customers ON
          travel_customers.trip_id = travel_trips.id AND
          travel_customers.client_id = #{params[:user_id]}
      WHERE
        (
          travel_trips.updated_at > travel_trips.seller_seen_at AND travel_trips.seller_id = #{params[:user_id]}
        ) OR
        (
          travel_trips.updated_at > travel_customers.seen_at AND travel_customers.client_id = #{params[:user_id]}
        )
    "
  }

  # params hash
  # - user_id
  # return id of last message for every unread trip
  @unread_messages_ids_sql = ->(params) {
    "
      SELECT travel_messages.id AS message_id
      FROM travel_trips
      LEFT OUTER JOIN travel_customers ON
          travel_customers.trip_id = travel_trips.id AND
          travel_customers.client_id = #{params[:user_id]}
      INNER JOIN travel_messages ON
        travel_messages.id = (
          SELECT id
          FROM travel_messages msg
          WHERE
            (
              msg.trip_id = travel_trips.id
            ) AND
            (
              (
                travel_customers.id IS NULL AND msg.created_at > travel_trips.seller_seen_at
              ) OR
              (
                travel_customers.id IS NOT NULL AND msg.created_at > travel_customers.seen_at
              )
            ) AND
            (
              msg.context = #{Travel::Message.contexts['message']}
            )
          ORDER BY created_at desc LIMIT 1
      )
      WHERE
        (
          (
            travel_trips.updated_at > travel_trips.seller_seen_at AND travel_trips.seller_id = #{params[:user_id]}
          ) OR
          (
            travel_trips.updated_at > travel_customers.seen_at AND travel_customers.client_id = #{params[:user_id]}
          )
        )
    "
  }

  # params hash
  # - user_id
  # return id of last transition for every unread trip
  @unread_seller_events_ids_sql = ->(params) {
    "
      SELECT travel_messages.id AS message_id
      FROM travel_trips
      INNER JOIN travel_messages ON
        travel_messages.trip_id = travel_trips.id AND
        travel_messages.context = #{Travel::Message.contexts['transition']} AND
        travel_messages.created_at > travel_trips.seller_seen_at
      WHERE
        travel_trips.updated_at > travel_trips.seller_seen_at AND
        travel_trips.seller_id = #{params[:user_id]}
    "
  }


end