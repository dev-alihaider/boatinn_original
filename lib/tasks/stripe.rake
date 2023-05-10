# frozen_string_literal: true

namespace :stripe do
  desc 'save status verification'
  task store_verify: :environment do |_t, _args|
    StripeAccount.find_each do |account|
      account.update_column(:account_verified, account.verified?)
    end
  end
end
