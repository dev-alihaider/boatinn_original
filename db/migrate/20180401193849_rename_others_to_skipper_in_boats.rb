# frozen_string_literal: true

class RenameOthersToSkipperInBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_column :boats, :others, :skipper
  end
end
