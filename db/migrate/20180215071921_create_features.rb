# frozen_string_literal: true

class CreateFeatures < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :features do |t|
      t.references  :category
      t.string :name
      t.integer :order
      t.timestamps
    end

    #add indexes
    add_index :features, :order
  end
end
