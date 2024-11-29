class UpdateTierListRankings < ActiveRecord::Migration[7.1]
  def change
    # Remove the existing index (if it exists)
    if index_exists?(:tier_list_rankings, [:tier_list_id, :rank])
      remove_index :tier_list_rankings, name: 'index_tier_list_rankings_on_tier_list_id_and_rank'
    end

    # Add a new unique index that excludes 'rank' from the uniqueness constraint
    add_index :tier_list_rankings, [:tier_list_id, :item_id, :ranked_by_id], unique: true, name: 'unique_tier_list_rankings'
  end
end
