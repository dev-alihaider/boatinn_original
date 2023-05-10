# frozen_string_literal: true

class AddEnabledToReviews < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :reviews, :enabled, :boolean, default: true, null: false
  end
end
