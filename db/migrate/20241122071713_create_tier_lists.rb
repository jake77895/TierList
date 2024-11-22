class CreateTierLists < ActiveRecord::Migration[7.1]
  def change
    create_table :tier_lists do |t|
      t.string :name, null: false
      t.integer :created_by_id, null: false
      t.string :short_description
      t.json :custom_fields
      t.boolean :published, default: false, null: false
      t.timestamps
    end

    # Add a foreign key constraint for created_by_id
    add_foreign_key :tier_lists, :users, column: :created_by_id
    # Add an index for better query performance
    add_index :tier_lists, :created_by_id
  end
end
