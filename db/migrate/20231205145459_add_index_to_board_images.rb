class AddIndexToBoardImages < ActiveRecord::Migration[7.1]
  def change
    add_index :board_images, [:board_id, :image_id], unique: true
    add_index :response_images, [:response_board_id, :image_id], unique: true
  end
end
