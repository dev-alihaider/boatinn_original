class AddNumberOfCancellationToPenalization < ActiveRecord::Migration[5.1]
  def up
    add_column :penalizations, :current_cancellations, :integer, default: 0

    Penalization.find_each do |penalization|
      seller = penalization.user
      cancelations = Penalization.canceled_travels_for_seller(seller).count
      penalization.update(current_cancellations: cancelations)
    end
  end

  def down
    remove_column :penalizations, :current_cancellations
  end
end
