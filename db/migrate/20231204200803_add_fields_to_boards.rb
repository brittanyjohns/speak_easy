class AddFieldsToBoards < ActiveRecord::Migration[7.1]
  def change
    add_column :boards, :static, :boolean, default: false
    add_column :boards, :favorite, :boolean, default: false
  end
end
