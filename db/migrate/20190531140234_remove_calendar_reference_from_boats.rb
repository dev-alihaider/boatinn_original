# frozen_string_literal: true

class RemoveCalendarReferenceFromBoats < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    remove_reference :boats, :calendar, index: true
  end
end
