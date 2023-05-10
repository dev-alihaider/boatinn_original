# frozen_string_literal: true

class AddComprefTitleAndLink < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    (1..12).each do |figure|
      add_column :homepage_settings, "compre_title_#{figure}", :string
      add_column :homepage_settings, "compre_link_#{figure}", :string
    end
  end
end
