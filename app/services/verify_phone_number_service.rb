# frozen_string_literal: true

class VerifyPhoneNumberService < TwilioService # :nodoc:
  # @param [String]  phone_number in format "+12345678901"
  # @return [VerifyPhoneNumberService]
  def initialize(phone_number)
    super()
    @phone_number = phone_number
  end

  def call
    Rails.logger.info "== Verify phone number with Twilio REST API ==\nNumber:"\
                      " #{@phone_number}"
    valid?
  end

  private

  def valid?
    response = @twilio_client.lookups.phone_numbers(@phone_number).fetch
    Rails.logger.debug response.inspect
    # NOTE: If invalid, throws an exception. If valid, no problems.
    response.phone_number
    return true
  rescue Twilio::REST::RestError => error
    Rails.logger.error error.inspect
    return false if error.code == 20_404
    raise error
  end
end
