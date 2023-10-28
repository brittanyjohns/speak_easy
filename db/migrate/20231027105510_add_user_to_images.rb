class AddUserToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :user_id, :integer
    add_column :images, :private, :boolean, default: true
  end
end
