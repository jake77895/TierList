# == Schema Information
#
# Table name: pages
#
#  id                :bigint           not null, primary key
#  about             :text
#  created_by        :integer
#  name              :string           not null
#  short_description :text
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_id         :integer
#
# Indexes
#
#  index_pages_on_created_by  (created_by)
#  index_pages_on_parent_id   (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by => users.id)
#
class Page < ApplicationRecord
  acts_as_tree order: "name"

  belongs_to :creator, class_name: "User", foreign_key: "created_by", optional: true

  

  has_many :pages_tier_lists
  has_many :tier_lists, through: :pages_tier_lists

  has_one_attached :profile_photo
  has_one_attached :cover_photo

  validates :name, presence: true
  validates :slug, uniqueness: true

  before_validation :generate_slug

  private

  def generate_slug
    self.slug ||= name.parameterize
  end
end
