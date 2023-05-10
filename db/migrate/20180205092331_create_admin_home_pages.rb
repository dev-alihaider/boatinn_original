class CreateAdminHomePages < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_home_pages do |t|

      t.timestamps
    end
  end
end
