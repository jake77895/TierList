class TierList < ApplicationRecord

  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id'
  serialize :custom_fields, Array
end
