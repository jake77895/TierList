# == Schema Information
#
# Table name: tier_list_rankings
#
#  id           :bigint           not null, primary key
#  rank         :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  item_id      :bigint           not null
#  ranked_by_id :bigint
#  tier_list_id :bigint           not null
#
# Indexes
#
#  index_tier_list_rankings_on_item_id       (item_id)
#  index_tier_list_rankings_on_ranked_by_id  (ranked_by_id)
#  index_tier_list_rankings_on_tier_list_id  (tier_list_id)
#  unique_tier_list_rankings                 (tier_list_id,item_id,ranked_by_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id) ON DELETE => cascade
#  fk_rails_...  (ranked_by_id => users.id)
#  fk_rails_...  (tier_list_id => tier_lists.id) ON DELETE => cascade
#
class TierListRanking < ApplicationRecord
  belongs_to :tier_list
  belongs_to :item
  belongs_to :ranked_by, class_name: "User", optional: true

  validates :rank, presence: true, inclusion: { in: 1..6 } # Ensure rank is between 1 and 6

end
