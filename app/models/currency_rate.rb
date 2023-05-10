# frozen_string_literal: true

# == Schema Information
#
# Table name: currency_rates
#
#  id            :bigint(8)        not null, primary key
#  from_currency :string
#  to_currency   :string
#  rate          :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#


class CurrencyRate < ApplicationRecord # :nodoc:
end
