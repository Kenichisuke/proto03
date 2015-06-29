class ChangeColumnnameOnCointype < ActiveRecord::Migration
  def change
  	rename_column :cointypes, :mini_in, :min_in
  	rename_column :cointypes, :fee_in, :fee_trd
  end
end
