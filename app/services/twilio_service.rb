# frozen_string_literal: true

class TwilioService # :nodoc:
  TWILIO_ACCOUNT_SID  = ENV['TWILIO_ACCOUNT_SID']
  TWILIO_AUTH_TOKEN   = ENV['TWILIO_AUTH_TOKEN']
  TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

  def initialize
    @twilio_client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID,
                                              TWILIO_AUTH_TOKEN)
  end
end
