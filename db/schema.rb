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

ActiveRecord::Schema[7.0].define(version: 2022_09_04_033138) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departures", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "location_id", null: false
    t.boolean "is_saved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_departures_on_location_id"
    t.index ["user_id"], name: "index_departures_on_user_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "location_id", null: false
    t.bigint "departure_id", null: false
    t.integer "distance", null: false
    t.boolean "is_saved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["departure_id"], name: "index_destinations_on_departure_id"
    t.index ["location_id"], name: "index_destinations_on_location_id"
    t.index ["user_id"], name: "index_destinations_on_user_id"
  end

  create_table "histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "destination_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "moving_distance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_histories_on_destination_id"
    t.index ["user_id"], name: "index_histories_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.string "address", null: false
    t.string "place_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "departures", "locations"
  add_foreign_key "departures", "users"
  add_foreign_key "destinations", "departures"
  add_foreign_key "destinations", "locations"
  add_foreign_key "destinations", "users"
  add_foreign_key "histories", "destinations"
  add_foreign_key "histories", "users"
end
