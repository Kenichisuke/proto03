class AddIndexToAutotrade < ActiveRecord::Migration
  def change
    add_index :autotrades, [:user_id, :coin_relation_id], unique: true
  end
end
