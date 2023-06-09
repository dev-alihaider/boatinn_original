# frozen_string_literal: true

class RailsSettingsMigration < ActiveRecord::Migration[5.1] # :nodoc:
  def self.up
    create_table :settings do |t|
      t.string     :var, null: false
      t.text       :value
      t.references :target, null: false, polymorphic: true
      t.timestamps null: true
    end
    add_index :settings, [:target_type, :target_id, :var], unique: true
  end

  def self.down
    drop_table :settings
  end
end
