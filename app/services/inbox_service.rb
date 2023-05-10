class InboxService

  BOOKING_TYPES = %i[travelling reservations].freeze
  UNREAD_STATUSES = %i[all readed unread].freeze
  CONVERSATIONS_PER_PAGE = 10

  def initialize(current_user, params)
    @current_user = current_user
    @search_params = parse_params(params)
  end

  def trips
    @trips ||= find_trips
  end

  def booking_type_selected?(type)
    parse_booking_type(type) == @search_params[:trip_type]
  end

  def unread_status_selected?(status)
    parse_unread_status(status) == @search_params[:unread_status]
  end

  def count_messages(unread_status: nil)
    selector = base_trip_selector
    selector = apply_filter_params_to_selector(selector,
      unread_status: unread_status || @search_params[:unread_status]
    )
    selector.count
  end

  def search_params(additional_params = nil)
    additional_params.present? ? @search_params.merge(additional_params) : @search_params
  end

  def traveling?
    @search_params[:trip_type] == :travelling
  end

  def reservations?
    @search_params[:trip_type] == :reservations
  end

  private

  def base_trip_selector
    return @base_trip_selector if defined?(@base_trip_selector)

    @base_trip_selector =
      if reservations?
        Travel::Trip.where(seller: @current_user)
      else
        Travel::Trip.joins(:customers).where(travel_customers: { client_id: @current_user.id } )
      end

    @base_trip_selector = @base_trip_selector.where.not(status: :pending)
  end

  def find_trips
    selector = base_trip_selector
      .order('updated_at DESC')
      .page(search_params[:page])
      .per(CONVERSATIONS_PER_PAGE)

    apply_filter_params_to_selector(selector,
        unread_status: @search_params[:unread_status]
     )
  end

  def apply_filter_params_to_selector(selector, unread_status: nil)
    apply_unread_status_to_selector(selector, unread_status) if unread_status.present?
  end

  def apply_unread_status_to_selector(selector, status)
    seller_unread = "travel_trips.updated_at > travel_trips.seller_seen_at"
    client_unread = "travel_trips.updated_at > travel_customers.seen_at"
    case status.to_s.to_sym
    when :unread
      selector.where(traveling? ? client_unread : seller_unread)
    when :readed
      selector.where.not(traveling? ? client_unread : seller_unread)
    else
      selector
    end
  end

  def parse_params(params)
    {
      trip_type: parse_booking_type(params[:trip_type]),
      unread_status: parse_unread_status(params[:unread_status]),
      page: params[:page] || 1
    }
  end

  def parse_booking_type(type)
    type = type.to_s.to_sym
    BOOKING_TYPES.include?(type) ? type : BOOKING_TYPES.first
  end

  def parse_unread_status(status)
    status = status.to_s.to_sym
    UNREAD_STATUSES.include?(status) ? status : UNREAD_STATUSES.first
  end

end
