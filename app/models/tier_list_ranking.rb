class TierListRanking < ApplicationRecord
  belongs_to :tier_list
  belongs_to :item
  belongs_to :ranked_by, class_name: "User", optional: true

  validates :rank, presence: true, inclusion: { in: 1..6 } # Ensure rank is between 1 and 6
end
