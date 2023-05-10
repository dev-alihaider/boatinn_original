class AddtypeToMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :context, :integer, default: 0
  end
end
