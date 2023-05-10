# frozen_string_literal: true
#
class AddProfileFieldsToUser < ActiveRecord::Migration[5.1]  # :nodoc:
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :gender, :integer
    add_column :users, :birthday, :date
    add_column :users, :language, :string
    add_column :users, :currency, :string
    add_column :users, :where_you_live, :string
    add_column :users, :describe_yourself, :text
  end
end
