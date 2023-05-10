class CoorectPeriodEndAtInPenalization < ActiveRecord::Migration[5.1]
  def change
    rename_column :penalizations, :period_and_at, :period_end_at
  end
end
