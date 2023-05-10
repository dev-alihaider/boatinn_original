# frozen_string_literal: true

class CreateFaqs < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :faqs do |t|
      t.integer :category_type, default: 0
      t.string :title
      t.text :descr
      t.boolean :visible, default: false, null: false
      t.integer :order, default: 0
      t.timestamps
    end

    #add indexes
    add_index :faqs, :category_type
    add_index :faqs, :order
  end
end
