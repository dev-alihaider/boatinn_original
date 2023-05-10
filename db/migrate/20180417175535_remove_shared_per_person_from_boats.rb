# frozen_string_literal: true

class RemoveSharedPerPersonFromBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_index :boats, :shared_per_person
    remove_column :boats, :shared_per_person, :decimal, precision: 8, scale: 2
  end
end
