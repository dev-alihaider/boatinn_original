# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever
# whenever --update-crontab

every 1.day do
  runner 'UpdateCurrencyRatesJob.perform_later'
  runner 'DestroyOutdatedBookingBlockingsJob.perform_later'
end
