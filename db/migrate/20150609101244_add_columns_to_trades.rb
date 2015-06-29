class AddColumnsToTrades < ActiveRecord::Migration
  def change
      add_column :trades, :coin_a_id, :integer
      add_column :trades, :coin_b_id, :integer
  end
end
