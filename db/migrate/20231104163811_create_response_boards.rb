class CreateResponseBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :response_boards do |t|
      t.string :name

      t.timestamps
    end
  end
end
