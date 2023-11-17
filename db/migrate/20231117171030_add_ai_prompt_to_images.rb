class AddAiPromptToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :ai_prompt, :text
  end
end
