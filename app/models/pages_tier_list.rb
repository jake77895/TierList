# == Schema Information
#
# Table name: pages_tier_lists
#
#  page_id      :bigint           not null
#  tier_list_id :bigint           not null
#
# Indexes
#
#  index_pages_tier_lists_on_page_id_and_tier_list_id  (page_id,tier_list_id) UNIQUE
#  index_pages_tier_lists_on_tier_list_id_and_page_id  (tier_list_id,page_id)
#
class PagesTierList < ApplicationRecord
  belongs_to :page
  belongs_to :tier_list
end
