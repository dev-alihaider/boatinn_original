class ChangeBoatClassic < ActiveRecord::Migration[5.1]
  def change
    change_column_default :boats, :classic, false
  end
end
