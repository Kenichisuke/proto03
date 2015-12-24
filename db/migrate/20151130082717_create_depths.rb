class CreateDepths < ActiveRecord::Migration
  def change
    create_table :depths do |t|
      t.references :coin_relation
      t.float :rate
      t.float :amt

      t.timestamps null: false
    end
  end
end
