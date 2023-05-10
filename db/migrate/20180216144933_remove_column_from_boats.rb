# frozen_string_literal: true

class RemoveColumnFromBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_column :boats, :year_of_construction
  end
end
