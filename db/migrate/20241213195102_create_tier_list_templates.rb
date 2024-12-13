class CreateTierListTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :tier_list_templates do |t|
      t.string :name, null: false
      t.text :short_description
      t.json :custom_fields, default: [] # JSON column for custom fields
      t.string :category1 # First category field
      t.string :category2 # Second category field
      t.integer :created_by_id, null: false # Reference to the user who created the template
      t.timestamps
    end

    add_index :tier_list_templates, :created_by_id
  end
end
