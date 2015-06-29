class ChangePrecision < ActiveRecord::Migration
  def change
  	change_column :acnts, :balance, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  	change_column :acnts, :locked_bal, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  end
end
