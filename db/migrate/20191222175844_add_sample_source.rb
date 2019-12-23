class AddSampleSource < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :source, :integer, null: false, default: 0, index: true
    add_column :samples, :source_id, :integer, null: true, index: true
  end
end
