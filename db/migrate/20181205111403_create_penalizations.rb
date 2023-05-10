class CreatePenalizations < ActiveRecord::Migration[5.1]
  def change
    create_table :penalizations do |t|
      t.references :user
      t.datetime :period_started_at
      t.datetime :period_and_at
      t.integer :current_penalty_cents, default: 0
      t.string :currency
      t.timestamps
    end
  end
end
