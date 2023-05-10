class AddShowboatToBoat < ActiveRecord::Migration[5.1]
  def change
    add_column :boats, :showboat, :boolean
  end
end
