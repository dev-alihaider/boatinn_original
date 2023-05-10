# frozen_string_literal: true

class UserDecorator < Draper::Decorator # :nodoc:
  delegate_all

  DEFAULT_FIRST_NAME = 'Jane'
  DEFAULT_LAST_NAME  = 'Doe'

  def user_name
    @user_name ||= "#{user_first_name} #{user_last_name}".strip
  end

  def user_first_name
    @user_first_name ||= object.first_name.presence || DEFAULT_FIRST_NAME
  end

  def user_last_name
    @user_last_name ||= object.last_name.presence || DEFAULT_LAST_NAME
  end

  def joined_at
    object.created_at.strftime('%B %Y')
  end
end
