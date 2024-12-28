# == Schema Information
#
# Table name: people
#
#  id               :bigint           not null, primary key
#  bank             :string
#  email            :string
#  grad_school      :string
#  group            :string
#  level            :string
#  name             :string
#  undergrad_school :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Person < ApplicationRecord

  has_one_attached :image

  validates :name, presence: true

  # Bank Groups Mapping
  BANK_GROUPS = {
    "Goldman Sachs" => ["Investment Banking Group", "Private Wealth Management", "Asset Management"],
    "Evercore" => ["Advisory Group", "Investment Banking Division"],
    "Morgan Stanley" => ["Capital Markets", "Research Division", "Sales & Trading"]
  }

  # Default Levels
  DEFAULT_GROUPS = ["Managing Director", "Executive Director", "Vice President"]

  def self.groups_for_bank(bank_name)
    BANK_GROUPS[bank_name] || DEFAULT_GROUPS
  end

  # Bank Levels Mapping
  BANK_LEVELS = {
    "Goldman Sachs" => ["Managing Director", "Executive Director", "Vice President"],
    "Evercore" => ["Partner", "Senior Managing Director", "Analyst"],
    "Morgan Stanley" => ["Director", "Vice President", "Associate"]
  }

  # Default Levels
  DEFAULT_LEVELS = ["Managing Director", "Executive Director", "Vice President"]

  def self.levels_for_bank(bank_name)
    BANK_LEVELS[bank_name] || DEFAULT_LEVELS
  end

end
