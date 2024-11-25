class CreateTierListRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :tier_list_rankings do |t|
      t.references :tier_list, null: false, foreign_key: { on_delete: :cascade } # Deletes rankings when tier_list is deleted
      t.references :item, null: false, foreign_key: { on_delete: :cascade }     # Deletes rankings when item is deleted
      t.integer :rank, null: false                                              # Rank position
      t.references :ranked_by, null: true, foreign_key: { to_table: :users }    # Tracks the user who ranked the item

      t.timestamps
    end

    # Add an index for faster lookups by tier_list_id and rank
    add_index :tier_list_rankings, [:tier_list_id, :rank], unique: true
  end
end
