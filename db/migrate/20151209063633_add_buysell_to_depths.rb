class AddBuysellToDepths < ActiveRecord::Migration
  def change
    add_column :depths, :buysell, :boolean
  end
end
