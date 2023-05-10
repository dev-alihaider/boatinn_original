# frozen_string_literal: true

module InboxHelper # :nodoc:
  def input_output_message_class(message)
    message.sender.id == current_user.id ? 'out' : 'in'
  end

  def conversation_users_options(conversation)
    options = conversation.users.map do |member|
      path = dashboard_inbox_path(conversation, from: member.id)
      [member.display_name, member.id, { data: { path: path } }]
    end
    options.unshift([t('users.inbox.show.filter_from_all_participants'), '',
                     { data: { path: dashboard_inbox_path(conversation) } }])
    options_for_select(options, params[:from].presence)
  end

  def transition_event_status(message)
    if message.trip.shared?
      transition_shared_status(message)
    else
      transition_classic_status(message)
    end
  end

  def transition_shared_status(message)
    locals = { date: transition_human_date(message), author_name: message.sender.display_name }
    if message.content == 'joined'
      if message.metadata[:number_of_guests] > 1
        t("users.inbox.show.transitions.joined_many", locals.merge(guests: message.metadata[:number_of_guests]))
      else
        t("users.inbox.show.transitions.joined", locals)
      end
    else
      t("users.inbox.show.transitions.#{message.content}", locals)
    end
  end

  def transition_classic_status(message)
    locals = { date: transition_human_date(message), author_name: message.sender.display_name }
    t("users.inbox.show.transitions.#{message.content}", locals)
  end

  def transition_human_date(message)
    if message.created_at.today?
      I18n.t("date.today_at", time: message.created_at.strftime('%R'))
    else
      message.created_at.strftime('%m/%d/%y %H:%M')
    end
  end

  def travel_user_verifications(user)
    verifications = [t('users.profile.verified_info')]
    verifications << [t('users.profile.email_adress')] if user.confirmed?
    verifications << [t('users.profile.phone_number')] if user.phone_verified?

    { text: verifications.join(', '), count: verifications.count }
  end
end
