class AddSamplesFields < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :note, :string
    add_column :samples, :repetition, :integer, default: 0, null: false
  end
end
