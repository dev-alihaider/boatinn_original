# frozen_string_literal: true

class AddCategoryType < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    add_column :categories, :category_type, :integer, default: 0
  end
end
