class AddAvgGradeToReview < ActiveRecord::Migration[5.1]
  def change
    add_column :reviews, :avg_grade, :decimal, precision: 3, scale: 2
  end
end
