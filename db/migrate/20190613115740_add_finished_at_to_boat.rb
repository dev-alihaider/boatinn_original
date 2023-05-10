class AddFinishedAtToBoat < ActiveRecord::Migration[5.1]
  def up
    add_column :boats, :finished_at, :datetime

    Boat.find_each do |boat|
      boat.update(finished_at: boat.updated_at) if boat.finished?
    end
  end

  def down
    remove_column :boats, :finished_at
  end
end
