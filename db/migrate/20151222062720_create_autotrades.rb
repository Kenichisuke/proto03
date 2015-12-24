class CreateAutotrades < ActiveRecord::Migration
  def change
    create_table :autotrades do |t|
      t.references :user, index: true, foreign_key: true
      t.references :coin_relation, index: true, foreign_key: true
      t.float :portion
      t.float :trig
      t.float :range

      t.timestamps null: false
    end
  end
end
