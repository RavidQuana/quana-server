class AddImageToRank < ActiveRecord::Migration[6.0]
  def change
    add_column :ranks, :image, :string

  end
end
