class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.references :tier_list, null: false, foreign_key: true
      t.jsonb :custom_field_values

      t.timestamps
    end
  end
end
