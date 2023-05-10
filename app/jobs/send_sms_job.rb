# frozen_string_literal: true

class SendSmsJob < ApplicationJob # :nodoc:
  queue_as :default

  def perform(recipient_id, message)
    recipient = User.find(recipient_id)
    return unless recipient.phone_verified?

    SendSmsService.new(recipient.phone_number, message).call
  end
end
