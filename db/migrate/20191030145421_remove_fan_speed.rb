class RemoveFanSpeed < ActiveRecord::Migration[6.0]
  def change
    remove_column :samples, :fan_speed, :integer, null: false, default: 0
  end
end
