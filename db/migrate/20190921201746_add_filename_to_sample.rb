class AddFilenameToSample < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :file_name, :string, null: false, default: ""  
  end
end
