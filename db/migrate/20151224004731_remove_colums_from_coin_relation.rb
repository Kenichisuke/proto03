class RemoveColumsFromCoinRelation < ActiveRecord::Migration
  def change
    remove_column :coin_relations, :rate_ref, :decimal
    remove_column :coin_relations, :book_trig, :float
    remove_column :coin_relations, :book_range, :float        
  end
end
