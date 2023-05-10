# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :messages do |t|
      t.references :conversation
      t.references :user
      t.text :content

      t.timestamps
    end
  end
end
