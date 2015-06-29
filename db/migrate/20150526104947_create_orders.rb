class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :coin_a_id
      t.integer :coin_b_id
      t.decimal :amt_a_org, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :amt_b_org, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :amt_a, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :amt_b, precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :rate, precision: 32, scale: 16, default: 1.0, null:false
      t.boolean :buysell
      t.integer :flag

      t.timestamps null: false
    end
    add_index :orders, [:coin_a_id, :coin_b_id]
    add_index :orders, :flag
    add_index :orders, :buysell   
  end
end
