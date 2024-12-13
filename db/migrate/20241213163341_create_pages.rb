class CreatePages < ActiveRecord::Migration[7.1]
 def change
    create_table :pages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :parent_id, index: true
      t.integer :created_by, index: true # Reference to users table
      t.timestamps
    end

    add_foreign_key :pages, :users, column: :created_by
  end
end
