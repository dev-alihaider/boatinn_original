# frozen_string_literal: true

class AddPriorityToAssets < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :assets, :priority, :integer, null: false, default: 0
  end
end
