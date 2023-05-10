# frozen_string_literal: true

MoneyRails.configure do |config|
  config.default_format = { thousands_separator: ' ', decimal_mark: '.' }
  config.default_currency = :eur
  config.locale_backend = :currency
end

