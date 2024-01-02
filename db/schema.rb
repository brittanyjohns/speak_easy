# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_02_030324) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "board_images", force: :cascade do |t|
    t.bigint "board_id", null: false
    t.bigint "image_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id", "image_id"], name: "index_board_images_on_board_id_and_image_id", unique: true
    t.index ["board_id"], name: "index_board_images_on_board_id"
    t.index ["image_id"], name: "index_board_images_on_image_id"
  end

  create_table "boards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "theme_color"
    t.string "grid_size"
    t.boolean "show_labels"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "next_board_id"
    t.integer "previous_board_id"
    t.integer "parent_id"
    t.boolean "static", default: false
    t.boolean "favorite", default: false
    t.integer "doc_id"
    t.index ["next_board_id"], name: "index_boards_on_next_board_id"
    t.index ["parent_id"], name: "index_boards_on_parent_id"
    t.index ["previous_board_id"], name: "index_boards_on_previous_board_id"
    t.index ["user_id"], name: "index_boards_on_user_id"
  end

  create_table "docs", force: :cascade do |t|
    t.string "name"
    t.string "documentable_type", null: false
    t.bigint "documentable_id", null: false
    t.text "image_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "raw_text"
    t.index ["documentable_type", "documentable_id"], name: "index_docs_on_documentable"
  end

  create_table "images", force: :cascade do |t|
    t.string "image_url"
    t.string "audio_url"
    t.string "label"
    t.string "image_prompt"
    t.boolean "send_request_on_save"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "private", default: true
    t.string "category"
    t.boolean "ai_generated", default: false
    t.integer "final_response_count", default: 0
    t.text "ai_prompt"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "response_boards", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "next_response_board_id"
    t.integer "previous_response_board_id"
    t.integer "parent_id"
    t.index ["next_response_board_id"], name: "index_response_boards_on_next_response_board_id"
    t.index ["parent_id"], name: "index_response_boards_on_parent_id"
    t.index ["previous_response_board_id"], name: "index_response_boards_on_previous_response_board_id"
  end

  create_table "response_images", force: :cascade do |t|
    t.bigint "response_board_id", null: false
    t.bigint "image_id", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "click_count", default: 0
    t.boolean "final_response", default: false
    t.index ["image_id"], name: "index_response_images_on_image_id"
    t.index ["response_board_id", "image_id"], name: "index_response_images_on_response_board_id_and_image_id", unique: true
    t.index ["response_board_id"], name: "index_response_images_on_response_board_id"
  end

  create_table "response_records", force: :cascade do |t|
    t.string "name"
    t.string "word_list"
    t.integer "response_image_ids", default: [], array: true
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "situation"
    t.string "word_array", default: [], array: true
    t.integer "response_board_id"
    t.index ["response_board_id"], name: "index_response_records_on_response_board_id"
    t.index ["word_array"], name: "index_response_records_on_word_array", using: :gin
  end

  create_table "user_images", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "image_id", null: false
    t.boolean "favorite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_user_images_on_image_id"
    t.index ["user_id"], name: "index_user_images_on_user_id"
  end

  create_table "user_selections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "words", default: [], array: true
    t.boolean "current", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "situation"
    t.index ["user_id"], name: "index_user_selections_on_user_id"
    t.index ["words"], name: "index_user_selections_on_words", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ai_enabled", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "board_images", "boards"
  add_foreign_key "board_images", "images"
  add_foreign_key "boards", "users"
  add_foreign_key "response_images", "images"
  add_foreign_key "response_images", "response_boards"
  add_foreign_key "user_images", "images"
  add_foreign_key "user_images", "users"
  add_foreign_key "user_selections", "users"
end
