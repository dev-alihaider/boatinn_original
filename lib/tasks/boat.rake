# frozen_string_literal: true

namespace :boat do
  desc 'Disable boat where seller have not payouts'
  task disable_without_payout: :environment do |_t, _args|
    Boat.find_each { |boat| boat.offline! unless boat.user.payoutable? }
  end
end
