class AddResponceAvgToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avg_response_rate, :decimal, precision: 5, scale: 2, default: 0
    add_column :users, :avg_response_seconds, :integer, default: 0
  end
end
