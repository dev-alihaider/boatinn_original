# frozen_string_literal: true

class RenameFaqsColumns < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    rename_column :faqs, :category_type, :category
    rename_column :faqs, :descr, :description
  end
end
