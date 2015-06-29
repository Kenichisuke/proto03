class ChangePrecisionMore < ActiveRecord::Migration
  def change
  	change_column :orders, :amt_a, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :orders, :amt_b, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :orders, :amt_a_org, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :orders, :amt_b_org, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :trades, :amt_a, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :trades, :amt_b, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :trades, :fee, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  end
end
