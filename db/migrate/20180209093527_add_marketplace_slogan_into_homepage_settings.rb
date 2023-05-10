# frozen_string_literal: true

class AddMarketplaceSloganIntoHomepageSettings < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :homepage_settings, :marketplace_slogan_enabled, :boolean, default: true, null: false, after: :marketplace_slogan
  end
end
