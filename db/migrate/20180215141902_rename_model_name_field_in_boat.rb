# frozen_string_literal: true

class RenameModelNameFieldInBoat < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_column :boats, :model_name, :name_model
  end
end
