# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141106011224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: true do |t|
    t.integer  "active",       default: 1
    t.integer  "user_id",                  null: false
    t.string   "display"
    t.integer  "last_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: true do |t|
    t.string  "display"
    t.string  "method",    default: "get"
    t.string  "url",                       null: false
    t.integer "substitue"
  end

  create_table "menus", force: true do |t|
    t.string  "group"
    t.string  "key"
    t.integer "order"
    t.integer "link_id", null: false
  end

  add_index "menus", ["group", "key"], name: "index_menus_on_group_and_key", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "chat_id",                null: false
    t.integer  "active",     default: 1
    t.string   "content"
    t.string   "extra"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["chat_id", "active"], name: "index_messages_on_chat_id_and_active", using: :btree
  add_index "messages", ["user_id", "chat_id"], name: "index_messages_on_user_id_and_chat_id", unique: true, using: :btree

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.string   "extra"
    t.datetime "s_time"
    t.datetime "e_time"
    t.datetime "expire"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", using: :btree
  add_index "posts", ["user_id", "expire"], name: "index_posts_on_user_id_and_expire", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "status"
    t.string   "alias_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["friend_id"], name: "index_relationships_on_friend_id", using: :btree
  add_index "relationships", ["user_id", "friend_id"], name: "index_relationships_on_user_id_and_friend_id", unique: true, using: :btree
  add_index "relationships", ["user_id"], name: "index_relationships_on_user_id", using: :btree

  create_table "talkers", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "chat_id",                null: false
    t.integer  "active",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "talkers", ["user_id", "active"], name: "index_talkers_on_user_id_and_active", using: :btree
  add_index "talkers", ["user_id", "chat_id"], name: "index_talkers_on_user_id_and_chat_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "login",               null: false
    t.string   "email",               null: false
    t.string   "phone"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
