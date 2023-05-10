# frozen_string_literal: true
# == Schema Information
#
# Table name: stripe_accounts
#
#  id                  :bigint(8)        not null, primary key
#  user_id             :bigint(8)
#  stripe_user_id      :string
#  stripe_account_type :string
#  publishable_key     :string
#  secret_key          :string
#  stripe_customer_id  :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_verified    :boolean          default(FALSE)
#  express_account_id  :string
#  payout_ready        :boolean          default(FALSE)
#

class StripeAccount < ApplicationRecord # :nodoc:
  belongs_to :user
  # deprecated, will be destroyed soon
  has_many :user_bank_accounts, dependent: :destroy

  # deprecated, will be destroyed soon
  def verified?
    !unverified?
  end

  # deprecated, will be destroyed soon
  def unverified?
    StripeActionsService.new.stripe_verification_fields(stripe_user_id).present?
  end

  # deprecated, will be destroyed soon
  def field_for_verification
    StripeActionsService.new.stripe_verification_fields(stripe_user_id)
  end
end
