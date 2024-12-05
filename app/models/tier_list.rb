# == Schema Information
#
# Table name: tier_lists
#
#  id                :bigint           not null, primary key
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
  serialize :custom_fields, Array
  has_one_attached :image
  has_many :tier_list_rankings, dependent: :destroy
  has_many :items

  # Extract field names from custom_fields JSON
  def field_names
    custom_fields.map { |field| field['name'] } if custom_fields.present?
  end

  def self.custom_field_names
    TierList.distinct.pluck(:field_names).flatten.compact.uniq
  end
  

  # Extract field types as a hash { "Field Name" => "Data Type" }
  # Extract field types from `custom_fields`
  def field_types
    custom_fields.map { |field| [field['name'], field['data_type']] } if custom_fields.present?
  end
  

end
