class CreateCoinRelations < ActiveRecord::Migration
  def change
    create_table :coin_relations do |t|
      t.integer :coin_a_id
      t.integer :coin_b_id
      t.decimal :step_min, precision: 32, scale: 8, null: false, default: 0.0
      t.decimal :rate_act, precision: 32, scale: 8, null: false, default: 0.0
      t.decimal :rate_ref, precision: 32, scale: 8, null: false, default: 0.0
      t.timestamps null: false
    end
    add_index :coin_relations, :coin_a_id
    add_index :coin_relations, :coin_b_id
    add_index :coin_relations, [:coin_a_id, :coin_b_id], unique: true
  end
end
