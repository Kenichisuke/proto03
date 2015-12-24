class AddLotMinToCoinRelation < ActiveRecord::Migration
  def change
    add_column :coin_relations, :lot_min, :decimal, precision: 32, scale: 8, default: 0.0
  end
end
