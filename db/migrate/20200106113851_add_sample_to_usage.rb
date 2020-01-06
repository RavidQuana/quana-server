class AddSampleToUsage < ActiveRecord::Migration[6.0]
    def change
      add_column :usages, :sample, :binary, :limit => 1.megabyte
      add_column :usages, :sample_process_status, :integer , null: false, default: 0
  end
end
