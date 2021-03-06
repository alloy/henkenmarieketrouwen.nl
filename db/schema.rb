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

ActiveRecord::Schema.define(version: 20140716120500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invitations", force: true do |t|
    t.string  "email",                                      null: false
    t.string  "token",                                      null: false
    t.string  "attendees",                                  null: false
    t.text    "note"
    t.boolean "sent",                       default: false
    t.boolean "confirmed",                  default: false
    t.boolean "attending_wedding",          default: false
    t.boolean "attending_dinner",           default: false
    t.integer "vegetarians",                default: 0,     null: false
    t.boolean "all_festivities",            default: false
    t.boolean "attending_brunch",           default: false
    t.boolean "attending_party_on_day_1",   default: false
    t.boolean "attending_party_on_day_2",   default: false
    t.string  "invitees",                                   null: false
    t.boolean "has_post_ceremony_plus_one", default: false
  end

end
