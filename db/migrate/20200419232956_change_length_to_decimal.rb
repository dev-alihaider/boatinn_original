class ChangeLengthToDecimal < ActiveRecord::Migration[5.1]
  def change
    change_column :boats, :length, :decimal
  end
end
