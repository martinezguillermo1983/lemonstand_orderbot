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

ActiveRecord::Schema.define(version: 20160406192058) do

  create_table "clients_links", force: :cascade do |t|
    t.integer "lemon_stand_client_id",              limit: 4
    t.integer "order_bot_client_id",                limit: 4
    t.integer "order_bot_sales_channel_id",         limit: 4
    t.string  "order_bot_sales_channel_name",       limit: 255
    t.integer "order_bot_order_guide_id",           limit: 4
    t.string  "order_bot_order_guide_name",         limit: 255
    t.integer "order_bot_account_group_id",         limit: 4
    t.string  "order_bot_account_group_name",       limit: 255
    t.integer "order_bot_distribution_center_id",   limit: 4
    t.string  "order_bot_distribution_center_name", limit: 255
    t.integer "order_bot_website_id",               limit: 4
    t.string  "order_bot_website_name",             limit: 255
  end

  add_index "clients_links", ["lemon_stand_client_id", "order_bot_client_id"], name: "index_clients_links_lemon_stand_client_id_order_bot_client_id", using: :btree
  add_index "clients_links", ["order_bot_client_id", "lemon_stand_client_id"], name: "index_clients_links_order_bot_client_id_lemon_stand_client_id", using: :btree

  create_table "customer_mappings", force: :cascade do |t|
    t.integer  "clients_link_id",         limit: 4
    t.integer  "lemon_stand_customer_id", limit: 4
    t.integer  "order_bot_account_id",    limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "customer_mappings", ["clients_link_id"], name: "index_customer_mappings_clients_link_id", using: :btree

  create_table "customer_shipping_mappings", force: :cascade do |t|
    t.integer  "customer_mapping_id",             limit: 4
    t.integer  "lemon_stand_shipping_address_id", limit: 4
    t.integer  "order_bot_customer_id",           limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "customer_shipping_mappings", ["customer_mapping_id"], name: "index_customer_shipping_mappings_customer_mapping_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "lemon_stand_clients", force: :cascade do |t|
    t.string   "client_code",  limit: 255
    t.string   "company_name", limit: 255
    t.string   "url",          limit: 255
    t.string   "api_key",      limit: 255
    t.string   "secret",       limit: 255
    t.string   "access_token", limit: 255
    t.datetime "created"
    t.datetime "expires"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "lemon_stand_clients_users", id: false, force: :cascade do |t|
    t.integer "user_id",               limit: 4, null: false
    t.integer "lemon_stand_client_id", limit: 4, null: false
  end

  add_index "lemon_stand_clients_users", ["lemon_stand_client_id", "user_id"], name: "index_lemon_stand_clients_users_lemon_stand_client_id_user_id", using: :btree
  add_index "lemon_stand_clients_users", ["user_id", "lemon_stand_client_id"], name: "index_lemon_stand_clients_users_user_id_lemon_stand_client_id", using: :btree

  create_table "order_bot_clients", force: :cascade do |t|
    t.string   "client_code",  limit: 255
    t.string   "company_name", limit: 255
    t.string   "url",          limit: 255
    t.string   "username",     limit: 255
    t.string   "password",     limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "order_bot_clients_users", id: false, force: :cascade do |t|
    t.integer "user_id",             limit: 4, null: false
    t.integer "order_bot_client_id", limit: 4, null: false
  end

  add_index "order_bot_clients_users", ["order_bot_client_id", "user_id"], name: "index_order_bot_clients_users_on_order_bot_client_id_and_user_id", using: :btree
  add_index "order_bot_clients_users", ["user_id", "order_bot_client_id"], name: "index_order_bot_clients_users_on_user_id_and_order_bot_client_id", using: :btree

  create_table "order_mappings", force: :cascade do |t|
    t.integer  "clients_link_id",      limit: 4
    t.integer  "lemon_stand_order_id", limit: 4
    t.integer  "order_bot_order_id",   limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "order_mappings", ["clients_link_id"], name: "index_order_mappings_clients_link_id", using: :btree

  create_table "product_mappings", force: :cascade do |t|
    t.integer  "clients_link_id",      limit: 4
    t.integer  "lemon_stand_order_id", limit: 4
    t.integer  "order_bot_order_id",   limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "product_mappings", ["clients_link_id"], name: "index_product_mappings_clients_link_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest", limit: 255
  end

end
