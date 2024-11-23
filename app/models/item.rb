class Item < ApplicationRecord
  belongs_to :tier_list
  has_one_attached :image

  validates :name, presence: true
end
