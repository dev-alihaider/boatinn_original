class AddShowboatToBoatTrue < ActiveRecord::Migration[5.1]
  def change
    change_column :boats, :showboat, :boolean, default: true
  end
end
