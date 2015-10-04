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

ActiveRecord::Schema.define(version: 20151001082957) do

  create_table "acnts", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "cointype_id", limit: 4
    t.decimal  "balance",                 precision: 32, scale: 8, default: 0.0, null: false
    t.decimal  "locked_bal",              precision: 32, scale: 8, default: 0.0, null: false
    t.string   "addr_in",     limit: 255
    t.string   "addr_out",    limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "acnt_num",    limit: 255
  end

  add_index "acnts", ["addr_in"], name: "index_acnts_on_addr_in", unique: true, using: :btree
  add_index "acnts", ["user_id", "cointype_id"], name: "index_acnts_on_user_id_and_cointype_id", unique: true, using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "coin_relations", force: :cascade do |t|
    t.integer  "coin_a_id",  limit: 4
    t.integer  "coin_b_id",  limit: 4
    t.decimal  "step_min",             precision: 32, scale: 8, default: 0.0, null: false
    t.decimal  "rate_act",             precision: 32, scale: 8, default: 0.0, null: false
    t.decimal  "rate_ref",             precision: 32, scale: 8, default: 0.0, null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "coin_relations", ["coin_a_id", "coin_b_id"], name: "index_coin_relations_on_coin_a_id_and_coin_b_id", unique: true, using: :btree
  add_index "coin_relations", ["coin_a_id"], name: "index_coin_relations_on_coin_a_id", using: :btree
  add_index "coin_relations", ["coin_b_id"], name: "index_coin_relations_on_coin_b_id", using: :btree

  create_table "coinios", force: :cascade do |t|
    t.integer  "cointype_id", limit: 4,                             default: 1,   null: false
    t.integer  "tx_category", limit: 4
    t.decimal  "amt",                     precision: 32, scale: 8,  default: 0.0, null: false
    t.integer  "flag",        limit: 4
    t.string   "txid",        limit: 255,                                         null: false
    t.string   "addr",        limit: 255
    t.integer  "acnt_id",     limit: 4
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.decimal  "fee",                     precision: 32, scale: 16, default: 0.0
  end

  add_index "coinios", ["acnt_id"], name: "index_coinios_on_acnt_id", using: :btree
  add_index "coinios", ["addr"], name: "index_coinios_on_addr", length: {"addr"=>10}, using: :btree
  add_index "coinios", ["flag"], name: "index_coinios_on_flag", using: :btree

  create_table "cointypes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "ticker",     limit: 255
    t.integer  "rank",       limit: 4
    t.float    "min_in",     limit: 24
    t.float    "fee_out",    limit: 24
    t.float    "fee_trd",    limit: 24
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.decimal  "init_amt",               precision: 32, scale: 10, default: 0.0, null: false
  end

  add_index "cointypes", ["ticker"], name: "index_cointypes_on_ticker", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "coin_a_id",  limit: 4
    t.integer  "coin_b_id",  limit: 4
    t.decimal  "amt_a_org",            precision: 32, scale: 8,  default: 0.0, null: false
    t.decimal  "amt_b_org",            precision: 32, scale: 8,  default: 0.0, null: false
    t.decimal  "amt_a",                precision: 32, scale: 8,  default: 0.0, null: false
    t.decimal  "amt_b",                precision: 32, scale: 8,  default: 0.0, null: false
    t.decimal  "rate",                 precision: 32, scale: 10, default: 0.0, null: false
    t.boolean  "buysell"
    t.integer  "flag",       limit: 4
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "orders", ["buysell"], name: "index_orders_on_buysell", using: :btree
  add_index "orders", ["coin_a_id", "coin_b_id"], name: "index_orders_on_coin_a_id_and_coin_b_id", using: :btree
  add_index "orders", ["flag"], name: "index_orders_on_flag", using: :btree

  create_table "price_hists", force: :cascade do |t|
    t.datetime "dattim"
    t.float    "st",         limit: 24
    t.float    "mx",         limit: 24
    t.float    "mn",         limit: 24
    t.float    "en",         limit: 24
    t.float    "vl",         limit: 24
    t.integer  "ty",         limit: 4
    t.integer  "coin_a_id",  limit: 4
    t.integer  "coin_b_id",  limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "price_hists", ["coin_a_id", "coin_b_id"], name: "index_price_hists_on_coin_a_id_and_coin_b_id", using: :btree
  add_index "price_hists", ["dattim"], name: "index_price_hists_on_dattim", using: :btree

  create_table "trades", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.decimal  "amt_a",                precision: 32, scale: 8, default: 0.0, null: false
    t.decimal  "amt_b",                precision: 32, scale: 8, default: 0.0, null: false
    t.decimal  "fee",                  precision: 32, scale: 8, default: 0.0, null: false
    t.integer  "flag",       limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "coin_a_id",  limit: 4
    t.integer  "coin_b_id",  limit: 4
  end

  add_index "trades", ["coin_a_id", "coin_b_id"], name: "index_trades_on_coin_a_id_and_coin_b_id", using: :btree
  add_index "trades", ["flag"], name: "index_trades_on_flag", using: :btree
  add_index "trades", ["order_id"], name: "index_trades_on_order_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,     null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "user_num",               limit: 255, default: "0"
    t.boolean  "admin",                              default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
