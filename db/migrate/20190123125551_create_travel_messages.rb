class CreateTravelMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_messages do |t|
      t.references :trip
      t.references :sender
      t.integer :context, default: 0
      t.text :content
      t.text :metadata
      t.timestamps
    end

    add_index :travel_messages, :context
  end
end
