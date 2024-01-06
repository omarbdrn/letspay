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

ActiveRecord::Schema.define(version: 20190505184324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  end

  create_table "accounts_merchants", id: false, force: :cascade do |t|
    t.integer "account_id",  null: false
    t.integer "merchant_id", null: false
    t.index ["account_id"], name: "index_accounts_merchants_on_account_id", using: :btree
    t.index ["merchant_id"], name: "index_accounts_merchants_on_merchant_id", using: :btree
  end

  create_table "bank_accounts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "merchant_id"
    t.string   "iban"
    t.string   "bic"
    t.string   "owner_name"
    t.string   "owner_street"
    t.string   "owner_city"
    t.string   "owner_region"
    t.string   "owner_zipcode"
    t.string   "owner_country"
    t.string   "mango_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["merchant_id"], name: "index_bank_accounts_on_merchant_id", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "payor_info_id"
    t.string   "mango_card_id"
    t.string   "card_type"
    t.string   "currency"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["payor_info_id"], name: "index_cards_on_payor_info_id", using: :btree
  end

  create_table "discount_purchases", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "discount_id"
    t.uuid     "purchase_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["discount_id"], name: "index_discount_purchases_on_discount_id", using: :btree
    t.index ["purchase_id"], name: "index_discount_purchases_on_purchase_id", using: :btree
  end

  create_table "discounts", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "merchant_id"
    t.integer  "amount_cents",    default: 0,     null: false
    t.string   "amount_currency", default: "USD", null: false
    t.string   "code"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "percentage",      default: 0,     null: false
    t.string   "message"
    t.boolean  "display_message", default: false
    t.index ["merchant_id"], name: "index_discounts_on_merchant_id", using: :btree
  end

  create_table "merchants", force: :cascade do |t|
    t.string   "name",                                                           null: false
    t.string   "api_key",                                                        null: false
    t.string   "site_url",                                                       null: false
    t.string   "terms_url",                                                      null: false
    t.string   "default_locale",                                 default: "en",  null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "mango_id"
    t.string   "mango_wallet_id"
    t.string   "slug"
    t.integer  "commission_percent_thousandth",                  default: 0
    t.string   "webhooks_url"
    t.string   "picture_url"
    t.string   "email_ticket"
    t.string   "pay_out_frequency"
    t.integer  "service_fee_cents",                              default: 0,     null: false
    t.string   "currency",                                       default: "USD"
    t.boolean  "auto_redirect_to_merchant_url",                  default: false
    t.date     "next_pay_out_date"
    t.boolean  "multicard_mode",                                 default: false
    t.boolean  "verify_webhook_response",                        default: false
    t.integer  "multicard_letspayer_participation_round_in_hours"
    t.integer  "multicard_leader_last_chance_round_in_hours"
    t.string   "payout_summary_email"
    t.boolean  "dispatchable_cart",                              default: false
    t.boolean  "white_label",                                    default: false
    t.string   "white_label_button_color",                       default: ""
    t.boolean  "disable_single_share",                           default: false
    t.boolean  "manual_purchase_confirmation_mode",              default: false
    t.boolean  "manual_multicard_mode",                          default: false
    t.string   "sender"
    t.string   "secret_token"
    t.index ["api_key"], name: "index_merchants_on_api_key", unique: true, using: :btree
    t.index ["slug"], name: "index_merchants_on_slug", unique: true, using: :btree
  end

  create_table "notifications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "account_id"
    t.uuid     "purchase_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["account_id", "purchase_id"], name: "index_notifications_on_account_id_and_purchase_id", unique: true, using: :btree
    t.index ["account_id"], name: "index_notifications_on_account_id", using: :btree
    t.index ["purchase_id"], name: "index_notifications_on_purchase_id", using: :btree
  end

  create_table "operations", force: :cascade do |t|
    t.datetime "failed_at"
    t.string   "failed_reason"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "type"
    t.string   "mango_id"
    t.string   "mango_author_id"
    t.string   "mango_status"
    t.string   "mango_card_id"
    t.string   "mango_redirect_url"
    t.datetime "pay_in_executed_at"
    t.string   "pay_in_mango_id"
    t.integer  "amount_cents",                 default: 0
    t.string   "amount_currency",              default: "USD"
    t.string   "initial_transaction_mango_id"
    t.string   "initial_transaction_type"
    t.string   "traceable_type"
    t.uuid     "traceable_id"
    t.string   "mango_result_code"
    t.integer  "merchant_id"
    t.index ["merchant_id"], name: "index_operations_on_merchant_id", using: :btree
    t.index ["traceable_type", "traceable_id"], name: "index_operations_on_traceable_type_and_traceable_id", using: :btree
  end

  create_table "payor_infos", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.string   "nationality"
    t.string   "country_of_residence"
    t.string   "mango_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "optin",                default: true
    t.string   "timezone"
    t.string   "language"
    t.string   "api_key"
    t.string   "merchant_reference"
  end

  create_table "letspayer_merchant_optins", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "payor_info_id"
    t.integer  "merchant_id"
    t.boolean  "value",         default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["merchant_id"], name: "index_letspayer_merchant_optins_on_merchant_id", using: :btree
    t.index ["payor_info_id"], name: "index_letspayer_merchant_optins_on_payor_info_id", using: :btree
  end

  create_table "products", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "merchant_reference"
    t.string   "label"
    t.integer  "amount_cents",       default: 0,     null: false
    t.string   "amount_currency",    default: "USD", null: false
    t.uuid     "purchase_id",                        null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "raw_amount_cents",   default: 0,     null: false
    t.jsonb    "price_bounds",       default: "{}",  null: false
    t.boolean  "variable_price",     default: false
    t.string   "terms_url"
    t.text     "description"
    t.index ["purchase_id"], name: "index_products_on_purchase_id", using: :btree
  end

  create_table "purchases", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "title",                                           null: false
    t.string   "callback_url",                                    null: false
    t.string   "merchant_reference",                              null: false
    t.string   "subtitle"
    t.string   "description"
    t.string   "picture_url"
    t.string   "comment"
    t.integer  "merchant_id",                                     null: false
    t.integer  "amount_cents",                    default: 0,     null: false
    t.string   "amount_currency",                 default: "USD", null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.uuid     "leader_share_id"
    t.integer  "state",                           default: 0,     null: false
    t.integer  "shares_count",                    default: 0,     null: false
    t.integer  "raw_amount_cents",                default: 0,     null: false
    t.integer  "maximum_participants_number"
    t.string   "payment_api_version",             default: "v1"
    t.datetime "multicard_confirmed_executed_at"
    t.boolean  "partially_successful_mode",       default: false
    t.string   "cancel_url",                      default: ""
    t.integer  "timeout_seconds",                 default: 0
    t.index ["merchant_id"], name: "index_purchases_on_merchant_id", using: :btree
  end

  create_table "share_products", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "product_id"
    t.uuid     "share_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "quantity",   default: 1,    null: false
    t.jsonb    "metadata",   default: "{}", null: false
    t.index ["product_id"], name: "index_share_products_on_product_id", using: :btree
    t.index ["share_id"], name: "index_share_products_on_share_id", using: :btree
  end

  create_table "shares", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "email",                             null: false
    t.uuid     "purchase_id",                       null: false
    t.integer  "account_id"
    t.integer  "amount_cents",      default: 0,     null: false
    t.string   "amount_currency",   default: "USD", null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "payor_info_id"
    t.datetime "expired_at"
    t.datetime "reminded_at"
    t.integer  "service_fee_cents", default: 0,     null: false
    t.index ["account_id"], name: "index_shares_on_account_id", using: :btree
    t.index ["payor_info_id"], name: "index_shares_on_payor_info_id", using: :btree
    t.index ["purchase_id"], name: "index_shares_on_purchase_id", using: :btree
  end

  add_foreign_key "accounts_merchants", "accounts"
  add_foreign_key "accounts_merchants", "merchants"
  add_foreign_key "bank_accounts", "merchants"
  add_foreign_key "cards", "payor_infos"
  add_foreign_key "discount_purchases", "discounts"
  add_foreign_key "discount_purchases", "purchases"
  add_foreign_key "discounts", "merchants"
  add_foreign_key "notifications", "accounts"
  add_foreign_key "notifications", "purchases"
  add_foreign_key "letspayer_merchant_optins", "merchants"
  add_foreign_key "letspayer_merchant_optins", "payor_infos"
  add_foreign_key "products", "purchases"
  add_foreign_key "purchases", "merchants"
  add_foreign_key "purchases", "shares", column: "leader_share_id"
  add_foreign_key "share_products", "products", on_delete: :cascade
  add_foreign_key "share_products", "shares"
  add_foreign_key "shares", "accounts"
  add_foreign_key "shares", "payor_infos"
  add_foreign_key "shares", "purchases"
end
