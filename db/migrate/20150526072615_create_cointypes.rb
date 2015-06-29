class CreateCointypes < ActiveRecord::Migration
  def change
    create_table :cointypes do |t|
      t.string :name
      t.string :ticker
      t.integer :rank
      t.float :min_in, default: 0.0, null:false 
      t.float :fee_out, default: 0.0, null:false
      t.float :fee_trd,  default: 0.0, null:false

      t.timestamps null: false
    end
    add_index :cointypes, :ticker,                unique: true
  end
end
