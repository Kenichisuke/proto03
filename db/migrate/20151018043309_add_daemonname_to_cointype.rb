class AddDaemonnameToCointype < ActiveRecord::Migration
  def change
    add_column :cointypes, :daemon, :string
  end
end
