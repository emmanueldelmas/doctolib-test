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

ActiveRecord::Schema.define(version: 20161116193027) do

  create_table "events", force: :cascade do |t|
    t.datetime "starts_at",        null: false
    t.datetime "ends_at",          null: false
    t.string   "kind",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.boolean  "weekly_recurring"
  end

  add_index "events", ["starts_at", "kind"], name: "index_events_on_starts_at_and_kind"
  add_index "events", ["starts_at"], name: "index_events_on_recurrence_day_and_starts_at"
  add_index "events", ["weekly_recurring", "kind", "starts_at"], name: "index_events_on_weekly_recurring_and_kind_and_starts_at"

end
