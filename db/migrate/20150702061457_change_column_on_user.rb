class ChangeColumnOnUser < ActiveRecord::Migration
  def change
  	rename_column :users, :usernum, :user_num
  	change_column :users, :user_num, :string
  end
end
