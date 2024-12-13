class CreateJoinTablePagesTierLists < ActiveRecord::Migration[7.1]
  def change
    create_join_table :pages, :tier_lists do |t|
      t.index [:page_id, :tier_list_id], unique: true
      t.index [:tier_list_id, :page_id]
    end
  end
end
