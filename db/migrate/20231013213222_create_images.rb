class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :image_url
      t.string :audio_url
      t.string :label
      t.string :image_prompt
      t.boolean :send_request_on_save

      t.timestamps
    end
  end
end
