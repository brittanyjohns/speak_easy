class AddSituationToResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :user_selections, :situation, :string
    add_column :response_records, :situation, :string
    add_column :response_records, :word_array, :string, array: true, default: []
    add_column :response_records, :response_board_id, :integer
    add_index :response_records, :word_array, using: "gin"
    add_index :response_records, :response_board_id
  end
end
