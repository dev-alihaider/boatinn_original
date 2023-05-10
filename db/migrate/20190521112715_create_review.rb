class CreateReview < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.references :sender
      t.references :trip
      t.references :receiver
      t.integer :status, default: 0
      t.integer :target
      t.text :public_review
      t.text :private_review
      t.text :reply_review
      t.datetime :reviewed_at
      t.datetime :replied_at
      t.integer :communication_grade, limit: 1
      t.integer :cleanliness_grade, limit: 1
      t.integer :boat_rules_grade, limit: 1
      t.integer :accuracy_grade, limit: 1
      t.integer :location_grade, limit: 1
      t.integer :check_in_grade, limit: 1
      t.integer :value_grade, limit: 1
      t.boolean :recommended
      t.timestamps
    end
  end
end
