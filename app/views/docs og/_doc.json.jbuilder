json.extract! doc, :id, :name, :documentable_id, :documentable_type, :image, :image_description, :created_at, :updated_at
json.url doc_url(doc, format: :json)
json.image url_for(doc.image)
