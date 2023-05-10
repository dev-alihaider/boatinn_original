# frozen_string_literal: true

class AddShortNameToLocations < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :locations, :short_name, :string
  end
end
