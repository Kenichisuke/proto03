class ChangePrecisionMore2 < ActiveRecord::Migration
  def change
  	change_column :orders, :rate, :decimal, precision: 32, scale: 10, default: 0.0, null: false
  end
end
