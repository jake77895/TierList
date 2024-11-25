# == Schema Information
#
# Table name: items
#
#  id                  :bigint           not null, primary key
#  custom_field_values :jsonb
#  description         :text
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tier_list_id        :bigint           not null
#
# Indexes
#
#  index_items_on_tier_list_id  (tier_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (tier_list_id => tier_lists.id)
#
class Item < ApplicationRecord
  belongs_to :tier_list
  has_one_attached :image
  has_many :tier_list_rankings, dependent: :destroy

  validates :name, presence: true
end
