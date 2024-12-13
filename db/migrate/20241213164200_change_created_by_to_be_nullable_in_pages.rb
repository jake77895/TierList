class ChangeCreatedByToBeNullableInPages < ActiveRecord::Migration[7.1]
  def change
    change_column_null :pages, :created_by, true
  end
end
