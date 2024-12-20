class CreateComments < ActiveRecord::Migration[7.1]
 def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tier_list, null: false, foreign_key: true
      t.references :item, foreign_key: true
      t.text :body, null: false
    
      t.timestamps
    end
  end
end
