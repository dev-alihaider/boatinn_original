# frozen_string_literal: true

class UpdateCurrencyRatesJob < ApplicationJob # :nodoc:
  queue_as :default

  def perform
    Fixer::UpdateRates.new(ENV['FIXER_CURRENCIES']).update_rates!
  end
end
