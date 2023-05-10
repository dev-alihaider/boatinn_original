class ConversationPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def initialize(conversation, current_user)
    @conversation = conversation
    @current_user = current_user
    @member = conversation.members.find_by(user: current_user)
    @booking =
      if @member.seller
        Booking.find_by(conversation: @conversation, seller: current_user)
      else
        Booking.find_by(conversation: @conversation, client: current_user)
      end
    if @booking.rental_shared? && @member.seller
      accepted_boook = Booking.not_canceled.find_by(conversation: @conversation)
      @booking = accepted_boook if accepted_boook.present?
    end
    @boat = @booking.boat
  end

  def last_activity_user
    @conversation.last_message_user
  end

  def link(link_name = nil, attr = nil)
    link_name = link_name || last_other_user.display_name
    link_to(link_name, dashboard_inbox_path(id: @conversation.id), attr)
  end

  def last_message
    @conversation.last_message
  end

  def last_other_user
    @last_other_user ||= begin
      user_ids = @conversation.members
                           .where(seller: !@conversation.seller?(@current_user))
                           .where.not(user: @current_user)
                           .pluck(:user_id)
      @conversation.messages.where(user_id: user_ids).last&.user || User.find(user_ids.last)
    end
  end

  def name
    @boat.listing_title
  end

  def booking_start_at
    @booking.start_at
  end

  def short_location
    @boat.location.short_name
  end

  def booking_type
    case @booking.rental_type.to_sym
    when :shared
      I18n.t("bookings.types.shared")
    when :sleepin
      I18n.t("bookings.types.sleepin")
    else
      I18n.t("bookings.types.classic")
    end
  end

  def booking_status
    @booking.status
  end

end
