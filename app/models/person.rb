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
#  linkedin         :string
#  location         :string
#  name             :string
#  undergrad_school :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Person < ApplicationRecord

  has_one_attached :image

  validates :name, presence: true
  validates :linkedin, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }, allow_blank: true

  # Scopes for filtering
  scope :by_bank, ->(bank) { where(bank: bank) if bank.present? }
  scope :by_level, ->(level) { where(level: level) if level.present? }
  scope :by_group, ->(group) { where(group: group) if group.present? }

  # Allowlisting searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id name email bank group level linkedin location undergrad_school
      grad_school created_at updated_at
    ]
  end

  # Allowlisting searchable associations (if any, for example, belongs_to or has_many relations)
  def self.ransackable_associations(auth_object = nil)
    []
  end

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

  # Bank Locations (Shared Across All Banks)
  BANK_LOCATIONS = [
    "Other",
    "New York",
    "California",
    "San Francisco",
    "Chicago",
    "London",
    "Hong Kong",
    "Singapore",
    "Tokyo",
    "Frankfurt",
    "Sydney",
    "Toronto",
    "Dubai"
  ]

  # Fetch Locations for Any Bank
  def self.locations_for_bank
    BANK_LOCATIONS
  end

end
