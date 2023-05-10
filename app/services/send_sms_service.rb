# frozen_string_literal: true

class SendSmsService < TwilioService # :nodoc:
  # @param [String]  phone_number in format "+12345678901"
  # @param [String]  message
  # @return [SendSmsService]
  def initialize(phone_number, message)
    super()
    @phone_number = phone_number
    @message = message
  end

  def call
    unless Rails.env.staging? || Rails.env.production?
      return Rails.logger.error('Sending SMS failed - environment NOT staging'\
                                ' OR production')
    end
    Rails.logger.info "== Sending SMS with Twilio REST API ==\nTo: "\
                      "#{@phone_number}\nBody: #{@message}"
    send_message
  end

  private

  # TODO: Add checking for message successful delivering.
  def send_message
    message = @twilio_client.messages.create(from: TWILIO_PHONE_NUMBER,
                                             to: @phone_number,
                                             body: @message)
    Rails.logger.debug message.inspect
  rescue Twilio::REST::TwilioError => error
    Rails.logger.error error.inspect
  end
end
