class RemoveProfilePhotoAndCoverPhotoFromPages < ActiveRecord::Migration[7.1]
  def change
    remove_column :pages, :profile_photo, :string
    remove_column :pages, :cover_photo, :string
  end
end
