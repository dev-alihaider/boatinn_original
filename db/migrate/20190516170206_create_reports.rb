# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :reports do |t|
      t.references :author
      t.references :reportable, polymorphic: true, index: true

      t.integer :reason
      t.string :details

      t.timestamps
    end
  end
end
