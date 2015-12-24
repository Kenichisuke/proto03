class AddBookmakeToCoinRelations < ActiveRecord::Migration
  def change
    add_column :coin_relations, :book_trig, :float
    add_column :coin_relations, :book_range, :float
  end
end
