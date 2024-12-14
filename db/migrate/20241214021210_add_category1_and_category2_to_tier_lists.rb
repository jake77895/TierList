class AddCategory1AndCategory2ToTierLists < ActiveRecord::Migration[7.1]
  def change
    add_column :tier_lists, :category1, :string
    add_column :tier_lists, :category2, :string
  end
end
