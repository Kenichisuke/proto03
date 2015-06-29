class AddFieldsToUsers < ActiveRecord::Migration
  def change
      add_column :users, :usernum, :integer, default: 0
      add_column :users, :admin, :boolean, default: false
  end
end
