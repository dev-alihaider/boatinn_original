class DeleteAdminHomePageTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :admin_home_pages
  end
end
