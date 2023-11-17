class CreateResponseRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :response_records do |t|
      t.string :name
      t.string :word_list
      t.integer :response_image_ids, array: true, default: []
      t.integer :user_id

      t.timestamps
    end
  end
end
