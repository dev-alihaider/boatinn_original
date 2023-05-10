# frozen_string_literal: true

class CreateCurrencyRates < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :currency_rates do |t|
      t.string :from_currency
      t.string :to_currency
      t.float :rate

      t.timestamps
    end
  end
end
