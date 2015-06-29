class AddColumToAcnt < ActiveRecord::Migration
  def change
    add_column :acnts, :acnt_num, :string
  end
end
