class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false, index: true, unique: true
    end

    create_table :sample_tags do |t|
      t.integer :sample_id, null: false, index: true
      t.integer :tag_id, null: false, index: true
    end

  end
end
