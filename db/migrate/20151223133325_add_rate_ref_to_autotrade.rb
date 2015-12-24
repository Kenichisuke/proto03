class AddRateRefToAutotrade < ActiveRecord::Migration
  def change
    add_column :autotrades, :rate_ref, :float
  end
end
