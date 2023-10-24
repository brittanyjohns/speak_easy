json.extract! board, :id, :user_id, :name, :theme_color, :grid_size, :created_at, :updated_at
json.url board_url(board, format: :json)
