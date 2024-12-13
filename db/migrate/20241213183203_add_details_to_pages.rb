class AddDetailsToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :short_description, :text
    add_column :pages, :profile_photo, :string
    add_column :pages, :cover_photo, :string
    add_column :pages, :about, :text
  end
end
