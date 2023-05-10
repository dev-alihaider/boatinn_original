# frozen_string_literal: true

module MoneyHelper # :nodoc:
  mattr_accessor :mailer_current_currency
  # TODO: WTF? Remove this crap
  def currency
    %w[EUR]
  end

  def currencies_for_footer
    %i[eur usd rub].map do |currency_name|
      currency = Money::Currency.new(currency_name)

      ["#{currency.iso_code} (#{currency.symbol})", currency.iso_code]
    end
  end

  def view_money(money, opts: {})
    money = Money.new(0) if money.zero? && money.is_a?(Integer)
    return money_format(money, opts: opts) if current_rate.blank?

    money_format(exchange_to_current_currency(money.cents), opts: opts)
  end

  def current_rate
    @current_rate ||= CurrencyRate.find_by(to_currency: current_currency)
  end

  # TODO: This helpers for backward compatibility with decimal price db storing
  # TODO: Migrate all decimal -> cents money in `Boat`, `SeasonRates` models
  # database money columns:
  #   decimal(8, 2) (currency with fractional) => integer (cents)
  # Refactor all code: full currency => cents calculations

  # Helper for money without symbol, used in JavaScript.
  # #to_f -> to avoid `undefined method 'zero?' for nil:NilClass` when price nil
  def in_current_currency(decim_price)
    if !decim_price.to_f.zero? && !current_currency_default?
      decim_price = exchange_to_current_currency(decim_price * 100)
    end

    humanized_money(decim_price, options_for_money_helper)
  end

  def in_default_currency(decim_price)
    if !decim_price.to_f.zero? && !current_currency_default?
      decim_price = exchange_to_default_currency(decim_price) * 100
    end

    humanized_money(decim_price, options_for_money_helper)
  end

  # TODO: Add per currency money formats to config/initializers/money.rb
  # TODO: Rename to `in_current_currency_with_symbol`
  # Note: For full format customization use option: { format: '%u %n' }
  # `humanized_money_with_symbol` also can be replaced by
  # `price_in_current_currency.format(options)
  # Fallback to default :thousands_separator, :decimal_mark
  def in_current_currency_with_sym(decim_price)
    if !decim_price.to_f.zero? && !current_currency_default?
      decim_price = exchange_to_current_currency(decim_price * 100)
    end

    opts = options_for_money_helper.slice!(:thousands_separator, :decimal_mark)

    humanized_money_with_symbol(decim_price, opts)
  end

  def current_currency
    return mailer_current_currency if mailer_current_currency.present?

    begin
      current_user&.currency || session[:current_currency] ||
        Money.default_currency.iso_code
    rescue Module::DelegationError => _error
      Money.default_currency.iso_code
    end
  end

  private

  # Exchange EUR price to current currency.
  def exchange_to_current_currency(eur_price)
    set_conversion_rates

    Money.new(eur_price, Money.default_currency.iso_code)
         .exchange_to(current_currency)
  end

  # Exchange price in current currency to default currency (EUR).
  def exchange_to_default_currency(price)
    set_conversion_rates

    Money.new(price, current_currency)
         .exchange_to(Money.default_currency.iso_code)
  end

  # TODO: Add Exchange rate store: Money.default_bank =
  # Money::Bank::VariableExchange.new(MyCustomStore.new)
  # TODO: Add memoize caching: not set if already set
  def set_conversion_rates
    CurrencyRate.all.each do |currency_rate|
      Money.add_rate(currency_rate.from_currency,
                     currency_rate.to_currency,
                     currency_rate.rate)

      # Set reverse rate without losses (because {USD, RUB} -> EUR not parsed).
      Money.add_rate(currency_rate.to_currency,
                     Money.default_currency.iso_code,
                     1.0 / currency_rate.rate)
    end
  end

  # just uncomment would you need format view
  # currency_symbol  # <span class="currency_symbol">$</span>
  # humanized_money money #  6.50
  # humanized_money_with_symbol money  # $6.50
  # money_without_cents money  # 6
  # money_without_cents_and_with_symbol money  # $6
  def money_format(money, opts: {})
    return money.symbol if opts[:only_symbol]
    return money.currency if opts[:only_currency]
    helps = ActionController::Base.helpers

    return helps.humanized_money(money) if opts[:only_digest]
    helps.humanized_money_with_symbol(money)
  end

  # thousands_separator: '', decimal_mark: '.' for JavaScript/Ruby float values
  def options_for_money_helper
    options = { no_cents: true, thousands_separator: '', decimal_mark: '.' }

    # Format with symbol after value for EUR currency.
    options[:format] = '%n %u' if current_currency_default?

    options
  end

  def current_currency_default?
    current_currency == Money.default_currency.iso_code
  end
end
