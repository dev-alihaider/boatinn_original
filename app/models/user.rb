# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                              :bigint(8)        not null, primary key
#  email                           :string           default(""), not null
#  encrypted_password              :string           default(""), not null
#  reset_password_token            :string
#  reset_password_sent_at          :datetime
#  remember_created_at             :datetime
#  sign_in_count                   :integer          default(0), not null
#  current_sign_in_at              :datetime
#  last_sign_in_at                 :datetime
#  current_sign_in_ip              :inet
#  last_sign_in_ip                 :inet
#  confirmation_token              :string
#  confirmed_at                    :datetime
#  confirmation_sent_at            :datetime
#  unconfirmed_email               :string
#  failed_attempts                 :integer          default(0), not null
#  unlock_token                    :string
#  locked_at                       :datetime
#  admin                           :boolean          default(FALSE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  phone_number                    :string
#  phone_verification_code         :string
#  phone_verification_code_sent_at :datetime
#  phone_verified                  :boolean          default(FALSE), not null
#  auth_via                        :string
#  uid_facebook                    :string
#  image_url_facebook              :string
#  uid_google_oauth2               :string
#  image_url_google_oauth2         :string
#  closed                          :boolean          default(FALSE)
#  stripe_customer_id              :string
#  first_name                      :string
#  last_name                       :string
#  nie                             :string
#  gender                          :integer
#  birthday                        :date
#  language                        :string
#  currency                        :string
#  where_you_live                  :string
#  describe_yourself               :text
#  blocked_at                      :datetime
#  display_name                    :string
#  avg_response_rate               :decimal(5, 2)    default(0.0)
#  avg_response_seconds            :integer          default(0)
#  facebook_data                   :jsonb            not null
#  google_oauth2_data              :jsonb            not null
#

class User < ApplicationRecord # :nodoc:
  include UserNotifications
  include UserCancelReasons
  include UserCv

  AGE_ALLOWED = 18
  REQUIRED_EMAILS = %i[
    reset_password_instructions
    confirmation_email
  ].freeze
  REQUIRED_SMS = %i[].freeze

  enum gender: %i[male female]

  has_settings do |settings|
    settings.key :notifications, defaults: { sms: true, email: true }
    settings.key :cancel_reasons
    settings.key :your_cv
  end

  has_one :image, class_name: 'Asset', as: :assetable, dependent: :destroy
  accepts_nested_attributes_for :image

  has_many :boats, dependent: :destroy
  has_many :seller_trips, class_name: 'Travel::Trip', foreign_key: :seller

  has_one :stripe_account, dependent: :destroy
  has_one :penalization, dependent: :destroy

  # Reviews: by user/about user.
  has_many :given_reviews, -> { published }, class_name: 'Review',
                                             foreign_key: :sender,
                                             dependent: :destroy
  has_many :received_reviews, -> { published }, class_name: 'Review',
                                                foreign_key: :receiver,
                                                dependent: :destroy

  has_many :reports_about, class_name: 'Report', as: :reportable,
                           dependent: :destroy

  has_and_belongs_to_many :wishes, class_name: 'Boat', dependent: :destroy

  scope :sellers, -> { where(id: Boat.select(:user_id).distinct) }

  scope :clients, lambda {
    where.not(id: Boat.select(:user_id).distinct)
         .or(User.where(id: Travel::Customer.select(:client_id).distinct))
  }

  validates :email, uniqueness: true

  # Include default modules. Others available are: :lockable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: %i[facebook google_oauth2]

  before_save do
    self.display_name = decorate.user_name
  end

  def self.find_with_omniauth(provider_data)
    find_by(:"uid_#{provider_data.provider}" => provider_data.uid)
  end

  # TODO: Add generated password email for further email sign in: UserMailer.delay.password_email(self, self.password)
  def self.create_with_omniauth(provider_data)
    user = new(model_params_with_omniauth(provider_data)
                 .merge(email: provider_data.info.email,
                        password: Devise.friendly_token[0, 20])
                 .merge(first_name: provider_data.info.first_name,
                        last_name: provider_data.info.last_name))
    user.skip_confirmation!
    user.save!
    user
  end

  # TODO: Commented lines is reserved for future use. For description see `20180212160530_add_omniauth_to_users.rb`.
  #   :"oauth_#{provider_data.provider}_token"      => provider_data.credentials.token,
  #   :"oauth_#{provider_data.provider}_expires_at" => Time.zone.at(provider_data.credentials.expires_at).to_datetime,
  #   :"locale_#{provider_data.provider}"           => provider_data.extra.raw_info.locale,
  def self.model_params_with_omniauth(provider_data)
    provider = provider_data.provider

    {
      auth_via: provider,
      "uid_#{provider}": provider_data.uid,
      "image_url_#{provider}": provider_data.info.image,
      "#{provider}_data": provider_data
    }
  end

  def update_with_omniauth(provider_data)
    update(User.model_params_with_omniauth(provider_data))
  end

  # @param [Integer|Nil] length = 5/6/8
  # @return [String] phone_verification_code
  # TODO: replace by `SecureRandom.random_number()`
  def generate_phone_verification_code(length = nil)
    length ||= 5
    rand(0..('9' * length).to_i).to_s.rjust(length, '0')
  end

  def verify_phone!(entered_code)
    return false unless phone_verification_code == entered_code

    update(phone_verified: true)
    true
  end

  def reset_phone_verification!(number, code_length = nil)
    old_phone_number = phone_number.to_s.dup

    update(phone_number: number,
           phone_verification_code:
             generate_phone_verification_code(code_length),
           phone_verification_code_sent_at: nil,
           phone_verified: false)

    if old_phone_number != self.phone_number
      NotifyService.phone_number_updated(self, old_phone_number)
    end
  end

  def send_phone_verification_code!(phone_number, code_length = nil)
    reset_phone_verification!(phone_number, code_length)

    message = I18n.t('users.phone_verification.sms_message',
                     verification_code: phone_verification_code)

    SendSmsService.new(phone_number, message).call

    # NOTE: For future usage. WARNING: Sidekiq must be started.
    # SendPhoneVerificationCodeJob.perform_later(phone_number, message)

    touch(:phone_verification_code_sent_at)
  end

  def verification_code_cooldown?
    phone_verification_code_sent_at? &&
      Time.zone.now < phone_verification_code_sent_at.advance(minutes: 2)
                                                     .in_time_zone
  end

  def verification_code_expired?
    phone_verification_code_sent_at? &&
      Time.zone.now > phone_verification_code_sent_at.advance(minutes: 10)
                                                     .in_time_zone
  end

  # Immediately sign out user (at next request) and display #inactive_message.
  def active_for_authentication?
    super && !blocked? && !closed?
  end

  def build_penalization
    super(currency: self.currency)
  end

  # `super` works next way:
  #   if access_locked? # => Devise::Models::Lockable.inactive_message
  #     :locked # => 'devise.failure.locked' = 'Your account is locked.'
  #   elsif !confirmed? # => Devise::Models::Confirmable.inactive_message
  #     :unconfirmed # => 'devise.failure.unconfirmed' =
  #       'You have to confirm your email address before continuing.'
  #   else # => Devise::Models::Authenticatable.inactive_message
  #     :inactive => 'devise.failure.inactive' =
  #       'Your account is not activated yet.'
  #   end
  def inactive_message
    if closed?
      :closed
    elsif blocked?
      :blocked
    else
      super
    end
  end

  def blocked?
    !blocked_at.nil?
  end

  def completed_reservation?
    @completed_reservation ||= Travel::Trip.where(seller: self).completed.exists?
  end

  def recommends_by_boat_owner_size
    @recommends_by_boat_owner_size ||= Review.received_for(self).published.guest.count
  end

  def reviews_about
    Review.where(receiver: self).published
  end

  def should_receive_email?(email_type = '')
    return false if email.blank?
    return true if REQUIRED_EMAILS.include?(email_type)
    settings(:notifications).email
  end

  def should_receive_sms?(sms_type = '')
    return false if phone_number.blank?
    return true if REQUIRED_SMS.include?(sms_type)
    settings(:notifications).sms
  end

  def cv_completed?
    [
      settings(:your_cv).present?,
      settings(:your_cv).value.all?{ |_k, v| v.present? }
    ].all?
  end

  # Seller user availability calendar start time.
  # @return Time
  def calendar_started_at
    @calendar_started_at ||= seller_trips.minimum(:check_in) ||
                             boats.minimum(:created_at) ||
                             created_at
  end

  # Seller user availability calendar finish time.
  # @return Time
  def calendar_finished_at
    @calendar_finished_at ||=
      [seller_trips.maximum(:check_out),
       boats.joins(:booking_blockings)
            .maximum('travel_booking_blockings.finished_at'),
       Time.zone.now].compact.max
  end

  # Seller user availability calendar boats available for booking time.
  # @return Time
  def calendar_available_until
    @calendar_available_until ||= calendar_finished_at + 2.years
  end

  def payoutable?
    stripe_account.present? && stripe_account.payout_ready?
  end

  protected

  def confirmation_required?
    !ENV['SKIP_EMAIL_CONFIRMATION']
  end

end
