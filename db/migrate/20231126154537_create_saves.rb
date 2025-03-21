class CreateSaves < ActiveRecord::Migration[7.1]
  def change
    create_table :saves do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.jsonb :save_data, default: {}
      t.integer :download_count, default: 0

      t.timestamps
    end
  end
end
