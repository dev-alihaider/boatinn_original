# frozen_string_literal: true

class RemoveReviewsRecommendedNull < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    change_column_default :reviews, :recommended, false
    change_column_null :reviews, :recommended, false, false
  end
end
