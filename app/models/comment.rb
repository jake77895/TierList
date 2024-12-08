# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  body         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  item_id      :bigint
#  tier_list_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_comments_on_item_id       (item_id)
#  index_comments_on_tier_list_id  (tier_list_id)
#  index_comments_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (tier_list_id => tier_lists.id)
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :tier_list
  belongs_to :item, optional: true # Optional association

  validates :body, presence: true
end
