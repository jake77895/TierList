# == Schema Information
#
# Table name: tier_list_templates
#
#  id                :bigint           not null, primary key
#  category1         :string
#  category2         :string
#  custom_fields     :json
#  name              :string           not null
#  short_description :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :integer          not null
#
# Indexes
#
#  index_tier_list_templates_on_created_by_id  (created_by_id)
#
class TierListTemplate < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"
  CATEGORY_OPTIONS = ["Option 1", "Option 2", "Option 3", "Option 4"].freeze

  # Validation for required fields
  validates :name, presence: true
end
