class AddReceiverReviewGivenToReview < ActiveRecord::Migration[5.1]
  def change
    add_column :reviews, :receiver_review_done, :boolean, default: false
  end
end
