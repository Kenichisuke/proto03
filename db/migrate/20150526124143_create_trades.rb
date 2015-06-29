class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer :order_id
      t.decimal :amt_a, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :amt_b, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :fee, precision: 32, scale: 16, default: 0.0, null:false
      t.integer :flag

      t.timestamps null: false
    end
    add_index :trades, :flag
    add_index :trades, :order_id    
  end
end
