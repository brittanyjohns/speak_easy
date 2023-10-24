class CreateBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :boards do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :name
      t.string :theme_color
      t.string :grid_size
      t.boolean :show_labels

      t.timestamps
    end
  end
end
