class CreateUserSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :user_selections do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :words
      t.boolean :current

      t.timestamps
    end
  end
end
