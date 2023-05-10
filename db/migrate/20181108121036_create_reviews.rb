# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_table :reviews do |t|
      t.references :user
      t.references :target_user

      t.string :public_review, null: false
      t.string :private_review
      t.integer :rating_cleanliness, null: false, default: 4
      t.integer :rating_communication, null: false, default: 4
      t.integer :rating_boat_rules, null: false, default: 4
      t.boolean :would_recommend, null: false, default: true

      t.timestamps
    end
  end
end
