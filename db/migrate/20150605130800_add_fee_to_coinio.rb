class AddFeeToCoinio < ActiveRecord::Migration
  def change  	
      add_column :coinios, :fee, :decimal, precision: 32, scale: 16, default: 0.0
      rename_column :coinios, :txtype, :tx_category
  end
end
