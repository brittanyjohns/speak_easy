class AddCountToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :response_images, :click_count, :integer, default: 0
    add_column :response_images, :final_response, :boolean, default: false
    add_column :images, :final_response_count, :integer, default: 0
  end
end
