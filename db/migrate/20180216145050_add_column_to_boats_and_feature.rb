# frozen_string_literal: true

class AddColumnToBoatsAndFeature < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    #add
    add_column :boats, :year_of_construction, :integer

    #add new into category
    add_column :categories, :order, :integer

    #add indexes
    add_index :boats, :year_of_construction
    add_index :categories, :order
  end
end
