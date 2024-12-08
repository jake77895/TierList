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
  has_many :comments, dependent: :destroy # Optional, depending on how you want to handle item deletion

  validates :name, presence: true

  def self.define_ransackers_for_custom_fields
    TierList.find_each do |tier_list|
      tier_list.custom_fields.each do |field|
        field_name = field['name'] || field[:name]
        next if field_name.nil? # Skip if name is nil
        sanitized_name = "custom_#{field_name.parameterize(separator: '_')}"
        
        Rails.logger.debug "Defining ransacker for: #{sanitized_name}"
      
        ransacker sanitized_name, formatter: proc { |v| v } do |_parent|
          Arel.sql("custom_field_values ->> '#{field_name}'")
        end
      end
    end
  end
  
  
  # Call this method automatically
  define_ransackers_for_custom_fields

  # Define ransackable attributes
  def self.ransackable_attributes(_auth_object = nil)
    default_attributes = %w[name description created_at updated_at]
    custom_attributes = TierList.find_each.flat_map do |tier_list|
      tier_list.custom_fields.map { |field| field['name'] || field[:name] }.compact
    end
    default_attributes + custom_attributes.map { |field_name| "custom_#{field_name.parameterize(separator: '_')}" }
  end

    # Define ransackable associations (if needed)
    def self.ransackable_associations(_auth_object = nil)
      %w[tier_list]
    end

# Scope to filter items based on a custom field and its value
scope :filter_by_custom_field, ->(field_name, value) {
  where("custom_field_values ->> ? ILIKE ?", field_name, "%#{value}%")
}

# Scope to handle numeric comparisons
scope :filter_by_custom_field_range, ->(field_name, min, max) {
  where("CAST(custom_field_values ->> ? AS INTEGER) BETWEEN ? AND ?", field_name, min, max)
}

# Scope for boolean fields
scope :filter_by_custom_field_boolean, ->(field_name, value) {
  normalized_value = value.to_s.downcase == "true" ? "1" : "0"
  where("custom_field_values ->> ? = ?", field_name, normalized_value)
}

# Scope for date fields
scope :filter_by_custom_field_date, ->(field_name, start_date, end_date) {
  where("TO_DATE(custom_field_values ->> ?, 'YYYY-MM-DD') BETWEEN ? AND ?", field_name, start_date, end_date)
}
end
