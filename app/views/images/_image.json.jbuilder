json.extract! image, :id, :image_url, :audio_url, :label, :send_request_on_save, :created_at, :updated_at
json.url image_url(image, format: :json)
