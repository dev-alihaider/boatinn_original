# frozen_string_literal: true

module UserNotifications # :nodoc:
  extend ActiveSupport::Concern

  included do
    def self.notifications
      { sms: I18n.t('users.notifications.sms'),
        email: I18n.t('email') }
    end
  end
end
