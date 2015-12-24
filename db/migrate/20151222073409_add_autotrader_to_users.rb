class AddAutotraderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :autotrader, :boolean, default: false
  end
end
