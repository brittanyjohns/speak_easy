class AddRawTextToDocs < ActiveRecord::Migration[7.1]
  def change
    add_column :docs, :raw_text, :text
    add_column :boards, :doc_id, :integer
  end
end
