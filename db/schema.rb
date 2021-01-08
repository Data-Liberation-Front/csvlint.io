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

ActiveRecord::Schema.define(version: 20210108235641) do

  create_table "packages", force: :cascade do |t|
    t.string   "url"
    t.string   "dataset"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schemas", force: :cascade do |t|
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "summaries", force: :cascade do |t|
    t.integer  "sources"
    t.string   "states"
    t.string   "hosts"
    t.string   "errors_breakdown"
    t.string   "warnings_breakdown"
    t.string   "info_messages_breakdown"
    t.string   "structure_breakdown"
    t.string   "schema_breakdown"
    t.string   "context_breakdown"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "validations", force: :cascade do |t|
    t.string   "filename"
    t.string   "url"
    t.string   "state"
    t.binary   "result"
    t.string   "csv_id"
    t.string   "parse_options"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
