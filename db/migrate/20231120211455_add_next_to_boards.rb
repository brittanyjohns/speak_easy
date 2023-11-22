class AddNextToBoards < ActiveRecord::Migration[7.1]
  def change
    add_column :boards, :next_board_id, :integer
    add_index :boards, :next_board_id
    add_column :boards, :previous_board_id, :integer
    add_index :boards, :previous_board_id
    add_column :boards, :parent_id, :integer
    add_index :boards, :parent_id
    add_column :response_boards, :next_response_board_id, :integer
    add_index :response_boards, :next_response_board_id
    add_column :response_boards, :previous_response_board_id, :integer
    add_index :response_boards, :previous_response_board_id
    add_column :response_boards, :parent_id, :integer
    add_index :response_boards, :parent_id
    add_column :users, :ai_enabled, :boolean, default: false
  end
end
