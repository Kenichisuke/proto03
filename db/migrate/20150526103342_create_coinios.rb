class CreateCoinios < ActiveRecord::Migration
  def change
    create_table :coinios do |t|
      t.integer :cointype_id, null: false, default: true
      t.integer :txtype
      t.decimal :amt, null: false, default: 0.0
      t.integer :flag
      t.string :txid, null: false
      t.string :addr
      t.integer :acnt_id

      t.timestamps null: false
    end
    add_index :coinios, :flag
    add_index :coinios, :acnt_id
    add_index :coinios, :addr, length: 10 
  end
end
