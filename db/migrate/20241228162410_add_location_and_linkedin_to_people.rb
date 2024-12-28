class AddLocationAndLinkedinToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :location, :string
    add_column :people, :linkedin, :string
  end
end
