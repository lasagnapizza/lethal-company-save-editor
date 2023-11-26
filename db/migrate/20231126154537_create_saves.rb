class CreateSaves < ActiveRecord::Migration[7.1]
  def change
    create_table :saves do |t|
      t.string :title
      t.text :description
      t.jsonb :save_data, default: {}

      t.timestamps
    end
  end
end
