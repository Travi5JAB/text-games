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

ActiveRecord::Schema.define(version: 2020_10_09_221008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.text "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "comment_text"
    t.bigint "game_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_comments_on_game_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "webpage"
    t.string "category"
    t.string "creator"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "mentions", id: :serial, force: :cascade do |t|
    t.string "mentionee_type"
    t.integer "mentionee_id"
    t.string "mentioner_type"
    t.integer "mentioner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentionee_id", "mentionee_type", "mentioner_id", "mentioner_type"], name: "mentions_mentionee_mentioner_idx", unique: true
    t.index ["mentionee_id", "mentionee_type"], name: "mentions_mentionee_idx"
    t.index ["mentionee_type", "mentionee_id"], name: "index_mentions_on_mentionee_type_and_mentionee_id"
    t.index ["mentioner_id", "mentioner_type"], name: "mentions_mentioner_idx"
    t.index ["mentioner_type", "mentioner_id"], name: "index_mentions_on_mentioner_type_and_mentioner_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "recipient_id"
    t.string "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "score"
    t.text "comment"
    t.bigint "user_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "reason"
    t.string "notes"
    t.bigint "game_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_reports_on_game_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "subcomments", force: :cascade do |t|
    t.text "comment_text"
    t.bigint "comment_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_subcomments_on_comment_id"
    t.index ["user_id"], name: "index_subcomments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_visits_on_game_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "comments", "games"
  add_foreign_key "comments", "users"
  add_foreign_key "games", "users"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "ratings", "games"
  add_foreign_key "ratings", "users"
  add_foreign_key "reports", "games"
  add_foreign_key "reports", "users"
  add_foreign_key "subcomments", "comments"
  add_foreign_key "subcomments", "users"
  add_foreign_key "visits", "games"
  add_foreign_key "visits", "users"
end
