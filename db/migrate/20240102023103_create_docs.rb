class CreateDocs < ActiveRecord::Migration[7.1]
  def change
    create_table :docs do |t|
      t.string :name
      t.references :documentable, polymorphic: true, null: false
      t.text :image_description

      t.timestamps
    end
  end
end
