class AddDepthFullupdateToCoinRelations < ActiveRecord::Migration
  def change
  	add_column :coin_relations, :depth_fullupdate, :datetime
  	add_column :coin_relations, :depth_upper, :decimal, precision: 32, scale: 8, default: 0.0
  	add_column :coin_relations, :depth_lower, :decimal, precision: 32, scale: 8, default: 0.0  	
  end
end
