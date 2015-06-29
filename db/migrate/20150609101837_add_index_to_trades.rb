class AddIndexToTrades < ActiveRecord::Migration
  def change
    add_index :trades, [:coin_a_id, :coin_b_id] 
  end
end
