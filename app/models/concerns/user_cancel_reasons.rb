# frozen_string_literal: true

module UserCancelReasons # :nodoc:
  extend ActiveSupport::Concern

  included do
    def self.cancel_reasons
      {
        reason_safety: I18n.t('users.account.reas_safety'),
        reason_privacy: I18n.t('users.account.reas_privacy'),
        reason_useful: I18n.t('users.account.reas_useful'),
        reason_understand: I18n.t('users.account.reas_understand'),
        reason_temp: I18n.t('users.account.reas_temp'),
        reason_other: I18n.t('users.account.reas_other'),
        reason_other_text: I18n.t('users.account.reas_other_text'),
        can_contact: I18n.t('users.account.can_contact')
      }
    end

    def self.cancel_reasons_without_text
      cancel_reasons.except(:reason_other_text, :can_contact)
    end

    def self.cancel_reasons_other_text
      cancel_reasons.slice(:reason_other_text)
    end
  end
end
