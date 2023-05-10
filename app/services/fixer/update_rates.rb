# frozen_string_literal: true

module Fixer
  class UpdateRates # :nodoc:
    attr_accessor :currencies
    attr_accessor :base

    def initialize(currencies)
      @currencies = currencies
    end

    def update_rates!
      fetch_rates.each do |currency, rate|
        next unless @currencies.include?(currency)

        currency_rate = CurrencyRate.find_or_create_by(from_currency: @base,
                                                       to_currency: currency)

        currency_rate.update!(rate: rate)
      end
    rescue StandardError => e
      Rails.logger.error e.inspect
    end

    private

    def fetch_rates
      rates_values = Fixer::Base.new.fetch_rates

      raise rates_values&.error unless rates_values

      @base = rates_values['base']

      rates_values['rates']
    end
  end
end
