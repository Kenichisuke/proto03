class CreatePriceHists < ActiveRecord::Migration
  def change
    create_table :price_hists do |t|
      t.datetime :dattim
      t.float :st
      t.float :mx
      t.float :mn
      t.float :en
      t.float :vl
      t.integer :ty
      t.integer :coin_a_id
      t.integer :coin_b_id

      t.timestamps null: false
    end
    add_index :price_hists, [:coin_a_id, :coin_b_id] 
    add_index :price_hists, :dattim
  end
end
