class AddCategoryToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :category, :string
    add_column :images, :ai_generated, :boolean, default: false
  end
end
