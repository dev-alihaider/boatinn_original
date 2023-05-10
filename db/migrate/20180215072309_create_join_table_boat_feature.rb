# frozen_string_literal: true

class CreateJoinTableBoatFeature < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    create_join_table :boats, :features do |t|
       t.index [:boat_id, :feature_id]
       t.index [:feature_id, :boat_id]
    end
  end
end
