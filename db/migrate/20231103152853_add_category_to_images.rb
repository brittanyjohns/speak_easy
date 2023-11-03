class AddCategoryToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :category, :string
  end
end
