# frozen_string_literal: true

module Api
  # REST JSON API for phone verification by SMS: send/verify code.
  class PhoneVerificationController < Api::GenericController
    before_action :authenticate_user!, :phone_already_verified?

    before_action(only: :send_code) { validate_param!(:phone_number) }
    before_action :validate_phone_number!, only: :send_code
    before_action :verification_code_cooldown?, only: :send_code

    before_action(only: :verify_code) { validate_param!(:verification_code) }
    before_action :verification_code_expired?, only: :verify_code

    # POST /api/phone_verification/send_code.json
    def send_code
      current_user.send_phone_verification_code!(params[:phone_number])
    end

    # POST /api/phone_verification/verify_code.json
    def verify_code
      return if current_user.verify_phone!(params[:verification_code])

      raise StandardError,
            t('users.phone_verification.failure.verification_code_incorrect')
    end

    private

    def validate_param!(param)
      return if params[param].present?

      raise ArgumentError, "Please include `#{param}` request param."
    end

    def phone_already_verified?
      return unless User.find_by(phone_number: params[:phone_number].presence ||
                                               current_user.phone_number,
                                 phone_verified: true)

      raise StandardError,
            t('users.phone_verification.failure.phone_number_already_verified')
    end

    def validate_phone_number!
      return if VerifyPhoneNumberService.new(params[:phone_number]).call

      raise StandardError,
            t('users.phone_verification.failure.invalid_phone_number')
    end

    def verification_code_cooldown?
      return unless current_user.verification_code_cooldown?

      raise StandardError,
            t('users.phone_verification.failure.verification_code_cooldown')
    end

    def verification_code_expired?
      return unless current_user.verification_code_expired?

      raise StandardError,
            t('users.phone_verification.failure.verification_code_expired')
    end
  end
end
