# frozen_string_literal: true

module UsersHelper # :nodoc:
  REVIEWS_TO_SHOW = 10

  def active_menu_item(item_name, by_index_action: false)
    if by_index_action
      return action_name == "index_#{item_name}" ? :active : nil
    end
    :active if controller_name == item_name
  end

  def active_menu_subitem(item_name, ctrl = nil)
    return 'active' if ctrl.present? && controller_name == ctrl
    'active' if action_name == item_name
  end

  def cc_class_by_name(type)
    type == 'visa' ? :visa : :mastercard
  end

  def not_current_user?(user)
    user.id != current_user.id
  end

  # @param [User] user
  def user_name(user = nil)
    (user || current_user).display_name
  end

  # @param [User] user
  def user_image_attachment_url(user = nil)
    user ||= current_user
    return unless user.image.present? && user.image.attachment.exists?

    user.image.attachment.url
  end

  ##
  # NOTE: Image search chain: uploaded -> Google -> Facebook -> Default.
  # @param [User] user
  def user_image_url(user = nil, with_path = true)
    user ||= current_user
    uploaded_image = user_image_attachment_url(user)
    facebook_image = user.facebook_data.present? &&
                     user.image_url_facebook.presence
    google_image = user.google_oauth2_data.present? &&
                   user.image_url_google_oauth2.presence
    default_image = with_path ? image_url('avatar-missing.png') : 'avatar-missing.png'

    uploaded_image || facebook_image || google_image || default_image
  end

  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = if column == sort_column && sort_direction == 'asc'
                  'desc'
                else
                  'asc'
                end
    icon = sort_direction == 'asc' ? 'fa fa-sort-asc' : 'fa fa-sort-desc'
    icon = column == sort_column ? icon : ''
    link_to "#{title} <i class='#{icon}'></i>".html_safe, column: column,
                                                          direction: direction
  end

  def birthday_select_options
    { prompt: { month: "",
                day: "",
                year: ""},
      with_css_classes: true,
      end_year: (end_year = Date.today.year - 17) - 100,
      start_year: end_year
     }
  end

  def omniauth_connect_label(status)
    if status
      t('users.profile.omniauth.connected')
    else
      t('users.profile.omniauth.disconnected')
    end
  end
end
