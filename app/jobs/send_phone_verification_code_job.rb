# frozen_string_literal: true

class SendPhoneVerificationCodeJob < ApplicationJob # :nodoc:
  queue_as :default

  def perform(phone_number, message)
    SendSmsService.new(phone_number, message).call
  end
end
