class CreateUserImages < ActiveRecord::Migration[7.0]
  def change
    create_table :user_images do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :image, null: false, foreign_key: true
      t.boolean :favorite

      t.timestamps
    end
  end
end
