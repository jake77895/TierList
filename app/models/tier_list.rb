# == Schema Information
#
# Table name: tier_lists
#
#  id                :bigint           not null, primary key
#  category1         :string
#  category2         :string
#  custom_fields     :json
#  image             :string
#  name              :string           not null
#  published         :boolean          default(FALSE), not null
#  short_description :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :integer          not null
#
# Indexes
#
#  index_tier_lists_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
class TierList < ApplicationRecord

  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id', optional: true
  serialize :custom_fields, type: Array

  has_many :pages_tier_lists
  has_many :pages, through: :pages_tier_lists

  has_one_attached :image
  has_many :tier_list_rankings, dependent: :destroy
  has_many :items
  has_many :comments, dependent: :destroy # Comments linked to a TierList are removed if it’s deleted

  def self.ransackable_attributes(auth_object = nil)
    %w[name category1 category2] # Add all attributes you want searchable
  end

  def self.ransackable_associations(auth_object = nil)
    [] # Allow no associations unless explicitly needed
  end

  def custom_fields_with_types
    # Ensure `custom_fields` is present and is an array
    return [] unless custom_fields.is_a?(Array)

    # Extract name and data type from each entry
    custom_fields.map do |field|
      {
        name: field['name'] || field[:name],
        data_type: field['data_type'] || field[:data_type]
      }
    end.compact # Remove any nil or invalid entries
  end

end
