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


  # Get field names from associated TierList
  def self.custom_field_names(context: nil)
    if context.is_a?(TierList)
      context.field_names || []
    elsif context.is_a?(Item)
      context.tier_list&.field_names || []
    else
      []
    end
  end

  # Dynamically define ransackers for each field
  custom_field_names(context: nil).each do |field_name|
    sanitized_name = "custom_#{field_name.parameterize(separator: '_')}"
    ransacker sanitized_name, formatter: proc { |v| v } do |_parent|
      Arel.sql("custom_field_values ->> '#{field_name}'")
    end
  end


  # Get field names from associated TierList
  def self.custom_field_names(context: nil)
    if context.is_a?(TierList)
      context.field_names || []
    elsif context.is_a?(Item)
      context.tier_list&.field_names || []
    else
      []
    end
  end

  # Dynamically define ransackers for each field
  custom_field_names(context: nil).each do |field_name|
    sanitized_name = "custom_#{field_name.parameterize(separator: '_')}"
    ransacker sanitized_name, formatter: proc { |v| v } do |_parent|
      Arel.sql("custom_field_values ->> '#{field_name}'")
    end
  end


  # Ransackable scope for JSONB fields
  scope :filter_by_jsonb_field, ->(key, value) {
    where("custom_field_values ->> ? = ?", key, value)
  }

 # Ransackable attributes for search
 def self.ransackable_attributes(_auth_object = nil)
  %w[name created_at updated_at] + custom_field_names(context: nil).map do |fn|
    "custom_#{fn.parameterize(separator: '_')}"
  end
end

  def self.sanitized_field_name(field_name)
    "custom_#{field_name.parameterize.underscore}"
  end

  # Ransackable associations
  def self.ransackable_associations(auth_object = nil)
    %w[tier_list]
  end

  scope :filter_by_jsonb_range, ->(key, min, max) {
    where("CAST(custom_field_values ->> ? AS integer) BETWEEN ? AND ?", key, min, max)
  }
end
