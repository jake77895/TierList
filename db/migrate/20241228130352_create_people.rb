class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.string :name
      t.string :bank
      t.string :group
      t.string :level
      t.string :email
      t.string :undergrad_school
      t.string :grad_school

      t.timestamps
    end
  end
end
