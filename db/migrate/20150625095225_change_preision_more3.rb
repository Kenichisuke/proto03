class ChangePreisionMore3 < ActiveRecord::Migration
  def change
  	change_column :coinios, :amt, :decimal, precision: 32, scale: 8, default: 0.0, null: false
  end
end
