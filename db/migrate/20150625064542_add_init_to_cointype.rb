class AddInitToCointype < ActiveRecord::Migration
  def change
    add_column :cointypes, :init_amt, :decimal, precision: 32, scale: 10, default: 0.0, null: false
  end
end
