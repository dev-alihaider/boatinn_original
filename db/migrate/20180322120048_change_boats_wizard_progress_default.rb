# frozen_string_literal: true

class ChangeBoatsWizardProgressDefault < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    change_column_null    :boats, :wizard_progress, false
    change_column_default :boats, :wizard_progress, from: nil, to: 0
  end
end
