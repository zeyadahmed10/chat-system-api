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

ActiveRecord::Schema[7.1].define(version: 2024_09_27_121726) do
  create_table "applications", charset: "latin1", force: :cascade do |t|
    t.string "application_token", null: false
    t.string "name", null: false
    t.integer "chats_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_token"], name: "index_applications_on_application_token", unique: true
  end

  create_table "chats", charset: "latin1", force: :cascade do |t|
    t.integer "chat_number", null: false
    t.string "application_token", null: false
    t.integer "messages_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_token", "chat_number"], name: "index_chats_on_application_token_and_chat_number", unique: true
    t.index ["application_token"], name: "index_chats_on_application_token"
  end

  create_table "messages", charset: "latin1", force: :cascade do |t|
    t.integer "message_number", null: false
    t.text "body", null: false
    t.string "application_token", null: false
    t.integer "chat_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_token", "chat_number", "message_number"], name: "idx_on_application_token_chat_number_message_number_51bfd3c604", unique: true
    t.index ["application_token", "chat_number"], name: "index_messages_on_application_token_and_chat_number"
  end

  add_foreign_key "chats", "applications", column: "application_token", primary_key: "application_token"
  add_foreign_key "messages", "applications", column: "application_token", primary_key: "application_token"
end
