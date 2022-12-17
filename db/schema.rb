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

ActiveRecord::Schema[7.0].define(version: 2022_12_16_114451) do
  create_table "friendships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "friend_id", null: false
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "player_1_id", null: false
    t.integer "player_2_id"
    t.string "uid", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "seen_by_1", default: false, null: false
    t.boolean "seen_by_2", default: false, null: false
    t.integer "words_count"
    t.integer "last_word_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "seen", default: false, null: false
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "endpoint"
    t.string "auth_key"
    t.string "p256dh_key"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "uid", null: false
    t.string "avatar"
    t.string "name"
    t.integer "telegram_id"
    t.string "user_name", null: false
    t.datetime "user_name_changed_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["user_name"], name: "index_users_on_user_name"
  end

  create_table "words", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.integer "round_id"
    t.string "word"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stamp", default: 0, null: false
    t.index ["game_id", "user_id", "round_id"], name: "index_words_on_game_id_and_user_id_and_round_id", unique: true
    t.index ["game_id"], name: "index_words_on_game_id"
    t.index ["user_id"], name: "index_words_on_user_id"
  end

  add_foreign_key "friendships", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "words", "games"
  add_foreign_key "words", "users"
end
