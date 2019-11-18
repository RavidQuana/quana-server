class CreateActivationCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :activation_codes do |t|
			t.integer				:owner_id, null: false
			t.string				:owner_type, null: false
			t.string				:code, null: false, index: true
			t.integer				:tries_count, default: 0, null: false
			t.datetime				:expires_at, null: false, index: true				

			t.timestamps			null: false    
    end
      add_index :activation_codes, [:owner_id, :owner_type], name: 'index_activation_codes_on_owner'
  end
end
