class AddSafeToUseToUsage < ActiveRecord::Migration[6.0]
  def change
    add_column :usages, :safe_to_use_status, :integer, null: false, default: 0

  end
end
