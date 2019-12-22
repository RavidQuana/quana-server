class CreateRanks < ActiveRecord::Migration[6.0]
  def change
    create_table :ranks do |t|
      t.string        :name, null: false
			t.integer				:minimal_number_of_scans, null: false
      t.timestamps

    end
  end
end
