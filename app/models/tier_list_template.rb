class TierListTemplate < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"

  # Validation for required fields
  validates :name, presence: true
end
