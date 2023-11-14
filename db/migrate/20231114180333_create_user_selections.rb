class CreateUserSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :user_selections do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :words, array: true, default: []
      t.boolean :current, default: true

      t.timestamps
    end
    add_index :user_selections, :words, using: "gin"
  end
end
