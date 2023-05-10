class CreateAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :assets do |t|
      t.attachment :attachment
      t.references :assetable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
