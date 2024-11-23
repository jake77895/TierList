class AddImageToTierLists < ActiveRecord::Migration[7.1]
  def change
    add_column :tier_lists, :image, :string
  end
end
