# frozen_string_literal: true

class AddCompreTitleForGlobalize < ActiveRecord::Migration[5.1] # :nodoc:
  def change

    (1..12).each do |i|
      add_column :homepage_setting_translations ,"compre_title_#{i}".to_sym, :string
    end

  end
end
