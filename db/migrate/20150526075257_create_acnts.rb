class CreateAcnts < ActiveRecord::Migration
  def change
    create_table :acnts do |t|
      t.integer :user_id
      t.integer :cointype_id
      t.decimal :balance,    precision: 32, scale: 16, default: 0.0, null:false
      t.decimal :locked_bal, precision: 32, scale: 16, default: 0.0, null:false
      t.string :addr_in
      t.string :addr_out

      t.timestamps null: false
    end
    add_index :acnts, [:user_id, :cointype_id],      unique: true
    add_index :acnts, :addr_in,                      unique: true
  end
end
