class TierListTemplate < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"

  # Validation for fields
  validates :name, presence: true
  validates :custom_fields, presence: true

  # Optional: Validation for custom fields
  validate :validate_custom_fields

  private

  def validate_custom_fields
    custom_fields.each do |field|
      if field[:name].blank?
        errors.add(:custom_fields, "Each field must have a name")
      end
    end
  end
end
