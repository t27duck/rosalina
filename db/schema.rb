# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_20_212316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "code_lists", primary_key: "discord_id", id: :string, force: :cascade do |t|
    t.boolean "public", default: false, null: false
    t.jsonb "system_codes", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "posted_entries", force: :cascade do |t|
    t.string "key", null: false
    t.string "slug", null: false
    t.string "url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key", "slug"], name: "index_posted_entries_on_key_and_slug", unique: true
  end

end
