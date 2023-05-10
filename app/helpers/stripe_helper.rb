# frozen_string_literal: true

module StripeHelper # :nodoc:
  def stripe_countries
    ['Austria', 'Belgium', 'Denmark', 'Finland', 'France',
     'Germany', 'Ireland', 'Italy', 'Luxembourg',
     'Netherlands', 'Norway', 'Portugal', 'Spain', 'Sweden',
     'Switzerland', 'United Kingdom']
  end

  def all_stripe_countries
    st = []
    stripe_countries.each do |c|
      c = ISO3166::Country.find_country_by_name(c)
      st << [c.name, c.alpha2]
    end
    st
  end

  def all_stripe_currencies
    st = []
    stripe_countries.each do |c|
      c = ISO3166::Country.find_country_by_name(c)
      st << c.currency.iso_code
    end
    st.uniq
  end

  def stripe_account_type
    %w[individual company]
  end
end
