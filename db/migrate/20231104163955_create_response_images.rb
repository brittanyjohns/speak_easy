class CreateResponseImages < ActiveRecord::Migration[7.0]
  def change
    create_table :response_images do |t|
      t.belongs_to :response_board, null: false, foreign_key: true
      t.belongs_to :image, null: false, foreign_key: true
      t.string :label, null: false

      t.timestamps
    end
  end
end
