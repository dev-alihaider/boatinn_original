class AddDisplayNameToUser < ActiveRecord::Migration[5.1]

  def up
    add_column :users, :display_name, :string, index: true
    User.find_each do |user|
      user.update_column(:display_name, user.decorate.user_name)
    end
  end

  def down
    remove_column :users, :display_name
  end

end
