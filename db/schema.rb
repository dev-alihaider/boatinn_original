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

ActiveRecord::Schema.define(version: 20210301122705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index "properties jsonb_path_ops", name: "index_ahoy_events_on_properties_jsonb_path_ops", using: :gin
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
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "assets", force: :cascade do |t|
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string "assetable_type"
    t.bigint "assetable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority", default: 0, null: false
    t.index ["assetable_type", "assetable_id"], name: "index_assets_on_assetable_type_and_assetable_id"
  end

  create_table "boats", force: :cascade do |t|
    t.integer "boat_type"
    t.integer "passengers_count"
    t.string "builders_name"
    t.string "name_model"
    t.decimal "length"
    t.string "listing_title"
    t.text "listing_description"
    t.integer "bathrooms_count"
    t.integer "cabins_count"
    t.integer "beds_count"
    t.integer "guest_number"
    t.integer "minimum_rental_time"
    t.integer "wizard_progress", default: 0, null: false
    t.bigint "user_id"
    t.decimal "cleaning_fee", precision: 8, scale: 2
    t.decimal "bedclosers_and_towels", precision: 8, scale: 2
    t.decimal "paddle_surf", precision: 8, scale: 2
    t.decimal "wellcome_pack", precision: 8, scale: 2
    t.decimal "fuel", precision: 8, scale: 2
    t.decimal "skipper", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year_of_construction"
    t.decimal "per_half_day", precision: 8, scale: 2
    t.decimal "per_day", precision: 8, scale: 2
    t.decimal "per_night", precision: 8, scale: 2
    t.decimal "per_week", precision: 8, scale: 2
    t.time "check_in_time"
    t.time "check_out_time"
    t.boolean "shared", default: false, null: false
    t.boolean "sleepin", default: false, null: false
    t.decimal "shared_price", precision: 8, scale: 2
    t.boolean "classic", default: false, null: false
    t.string "sleepin_description"
    t.integer "sleepin_max_passengers"
    t.decimal "sleepin_per_night", precision: 8, scale: 2
    t.string "shared_description"
    t.integer "shared_min_passengers"
    t.integer "shared_max_passengers"
    t.boolean "instant_booking_classic", default: false, null: false
    t.integer "cancellation", default: 0, null: false
    t.time "shared_check_in_time"
    t.time "shared_check_out_time"
    t.time "sleepin_check_in_time"
    t.time "sleepin_check_out_time"
    t.integer "sleepin_extra_guests"
    t.decimal "sleepin_extra_price", precision: 8, scale: 2
    t.integer "captain", default: 0, null: false
    t.string "port"
    t.boolean "instant_booking_sleepin", default: false, null: false
    t.boolean "instant_booking_shared", default: false, null: false
    t.integer "sleepin_min_rental_time"
    t.text "rating_hash", default: "---\n:count: 0\n:accuracy_avg: 0\n:communication_avg: 0\n:cleanliness_avg: 0\n:location_avg: 0\n:check_in_avg: 0\n:value_avg: 0\n"
    t.datetime "finished_at"
    t.boolean "showboat", default: true
    t.index ["bathrooms_count"], name: "index_boats_on_bathrooms_count"
    t.index ["beds_count"], name: "index_boats_on_beds_count"
    t.index ["cabins_count"], name: "index_boats_on_cabins_count"
    t.index ["guest_number"], name: "index_boats_on_guest_number"
    t.index ["length"], name: "index_boats_on_length"
    t.index ["passengers_count"], name: "index_boats_on_passengers_count"
    t.index ["shared_max_passengers"], name: "index_boats_on_shared_max_passengers"
    t.index ["shared_min_passengers"], name: "index_boats_on_shared_min_passengers"
    t.index ["sleepin_extra_guests"], name: "index_boats_on_sleepin_extra_guests"
    t.index ["sleepin_extra_price"], name: "index_boats_on_sleepin_extra_price"
    t.index ["sleepin_max_passengers"], name: "index_boats_on_sleepin_max_passengers"
    t.index ["sleepin_per_night"], name: "index_boats_on_sleepin_per_night"
    t.index ["user_id"], name: "index_boats_on_user_id"
    t.index ["wizard_progress"], name: "index_boats_on_wizard_progress"
    t.index ["year_of_construction"], name: "index_boats_on_year_of_construction"
  end

  create_table "boats_features", id: false, force: :cascade do |t|
    t.bigint "boat_id", null: false
    t.bigint "feature_id", null: false
    t.index ["boat_id", "feature_id"], name: "index_boats_features_on_boat_id_and_feature_id"
    t.index ["feature_id", "boat_id"], name: "index_boats_features_on_feature_id_and_boat_id"
  end

  create_table "boats_users", id: false, force: :cascade do |t|
    t.bigint "boat_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["boat_id", "user_id"], name: "index_boats_users_on_boat_id_and_user_id", unique: true
    t.index ["boat_id"], name: "index_boats_users_on_boat_id"
    t.index ["user_id"], name: "index_boats_users_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.integer "category_type", default: 0
    t.index ["order"], name: "index_categories_on_order"
  end

  create_table "currency_rates", force: :cascade do |t|
    t.string "from_currency"
    t.string "to_currency"
    t.float "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faq_translations", force: :cascade do |t|
    t.integer "faq_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.index ["faq_id"], name: "index_faq_translations_on_faq_id"
    t.index ["locale"], name: "index_faq_translations_on_locale"
  end

  create_table "faqs", force: :cascade do |t|
    t.integer "category", default: 0
    t.boolean "visible", default: false, null: false
    t.integer "order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_faqs_on_category"
    t.index ["order"], name: "index_faqs_on_order"
  end

  create_table "features", force: :cascade do |t|
    t.bigint "category_id"
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_features_on_category_id"
    t.index ["order"], name: "index_features_on_order"
  end

  create_table "homepage_setting_image_translations", force: :cascade do |t|
    t.integer "homepage_setting_image_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description"
    t.index ["homepage_setting_image_id"], name: "index_cbab70955e053231218fdb6b6b3d876df0f1cf23"
    t.index ["locale"], name: "index_homepage_setting_image_translations_on_locale"
  end

  create_table "homepage_setting_images", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "homepage_setting_id"
    t.string "section_slug"
    t.string "link"
    t.index ["homepage_setting_id"], name: "index_homepage_setting_images_on_homepage_setting_id"
  end

  create_table "homepage_setting_translations", force: :cascade do |t|
    t.integer "homepage_setting_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "search_bar_title"
    t.string "search_bar_status"
    t.string "marketplace_slogan"
    t.string "community_for_sharing_title"
    t.text "community_for_sharing_descr"
    t.string "community_for_sharing_title_image_1"
    t.text "community_for_sharing_descr_image_1"
    t.string "community_for_sharing_title_image_2"
    t.text "community_for_sharing_descr_image_2"
    t.string "community_for_sharing_title_image_3"
    t.text "community_for_sharing_descr_image_3"
    t.string "add_listing_section_title"
    t.text "add_listing_section_descr"
    t.string "add_listing_section_title_image_1"
    t.text "add_listing_section_title_descr_1"
    t.string "add_listing_section_title_image_2"
    t.text "add_listing_section_title_descr_2"
    t.string "add_listing_section_title_image_3"
    t.text "add_listing_section_title_descr_3"
    t.string "add_listing_section_title_image_4"
    t.text "add_listing_section_title_descr_4"
    t.string "compre_title_1"
    t.string "compre_title_2"
    t.string "compre_title_3"
    t.string "compre_title_4"
    t.string "compre_title_5"
    t.string "compre_title_6"
    t.string "compre_title_7"
    t.string "compre_title_8"
    t.string "compre_title_9"
    t.string "compre_title_10"
    t.string "compre_title_11"
    t.string "compre_title_12"
    t.index ["homepage_setting_id"], name: "index_homepage_setting_translations_on_homepage_setting_id"
    t.index ["locale"], name: "index_homepage_setting_translations_on_locale"
  end

  create_table "homepage_settings", force: :cascade do |t|
    t.boolean "header_settings", default: true, null: false
    t.boolean "cover_photo_slideshow", default: true, null: false
    t.boolean "search_bar_location", default: true, null: false
    t.string "marketplace_slogan"
    t.boolean "html_block", default: true, null: false
    t.boolean "community_for_sharing", default: true, null: false
    t.boolean "community_preferences", default: true, null: false
    t.boolean "add_listing_section", default: true, null: false
    t.boolean "experience_section", default: true, null: false
    t.boolean "footer_settings", default: true, null: false
    t.string "search_bar_title"
    t.string "search_bar_status"
    t.string "community_for_sharing_title"
    t.string "community_for_sharing_color"
    t.text "community_for_sharing_descr"
    t.string "community_for_sharing_title_image_1"
    t.text "community_for_sharing_descr_image_1"
    t.string "community_for_sharing_title_image_2"
    t.text "community_for_sharing_descr_image_2"
    t.string "community_for_sharing_title_image_3"
    t.text "community_for_sharing_descr_image_3"
    t.string "add_listing_section_title"
    t.text "add_listing_section_descr"
    t.string "add_listing_section_strip_color"
    t.string "add_listing_section_title_image_1"
    t.text "add_listing_section_title_descr_1"
    t.string "add_listing_section_title_image_2"
    t.text "add_listing_section_title_descr_2"
    t.string "add_listing_section_title_image_3"
    t.text "add_listing_section_title_descr_3"
    t.string "add_listing_section_title_image_4"
    t.text "add_listing_section_title_descr_4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "marketplace_slogan_enabled", default: true, null: false
    t.string "compre_title_1"
    t.string "compre_link_1"
    t.string "compre_title_2"
    t.string "compre_link_2"
    t.string "compre_title_3"
    t.string "compre_link_3"
    t.string "compre_title_4"
    t.string "compre_link_4"
    t.string "compre_title_5"
    t.string "compre_link_5"
    t.string "compre_title_6"
    t.string "compre_link_6"
    t.string "compre_title_7"
    t.string "compre_link_7"
    t.string "compre_title_8"
    t.string "compre_link_8"
    t.string "compre_title_9"
    t.string "compre_link_9"
    t.string "compre_title_10"
    t.string "compre_link_10"
    t.string "compre_title_11"
    t.string "compre_link_11"
    t.string "compre_title_12"
    t.string "compre_link_12"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.decimal "lat", precision: 11, scale: 8
    t.decimal "lng", precision: 11, scale: 8
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "boat_id"
    t.string "short_name"
    t.index ["boat_id"], name: "index_locations_on_boat_id"
    t.index ["lat", "lng"], name: "index_locations_on_lat_and_lng"
    t.index ["lat"], name: "index_locations_on_lat"
    t.index ["lng"], name: "index_locations_on_lng"
  end

  create_table "penalizations", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "period_started_at"
    t.datetime "period_end_at"
    t.integer "current_penalty_cents", default: 0
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_cancellations", default: 0
    t.index ["user_id"], name: "index_penalizations_on_user_id"
  end

  create_table "prewizard_setting_translations", force: :cascade do |t|
    t.integer "prewizard_setting_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rent_your_boat_title_main"
    t.string "rent_your_boat_strip_color"
    t.string "rent_your_boat_title_1"
    t.text "rent_your_boat_descr_1"
    t.string "rent_your_boat_title_2"
    t.text "rent_your_boat_descr_2"
    t.string "rent_your_boat_title_3"
    t.text "rent_your_boat_descr_3"
    t.string "rent_your_boat_title_4"
    t.text "rent_your_boat_descr_4"
    t.string "explain_settings_title_1"
    t.string "explain_settings_strip_color_1"
    t.text "explain_settings_descr_1"
    t.string "explain_settings_title_2"
    t.string "explain_settings_strip_color_2"
    t.text "explain_settings_descr_2"
    t.string "explain_settings_title_3"
    t.string "explain_settings_strip_color_3"
    t.text "explain_settings_descr_3"
    t.string "safety_settings_title_main"
    t.string "safety_settings_title_1"
    t.text "safety_settings_descr_1"
    t.string "safety_settings_title_2"
    t.text "safety_settings_descr_2"
    t.string "safety_settings_title_3"
    t.text "safety_settings_descr_3"
    t.index ["locale"], name: "index_prewizard_setting_translations_on_locale"
    t.index ["prewizard_setting_id"], name: "index_prewizard_setting_translations_on_prewizard_setting_id"
  end

  create_table "prewizard_settings", force: :cascade do |t|
    t.boolean "rent_your_boat", default: true, null: false
    t.boolean "explain_settings", default: true, null: false
    t.boolean "safety_settings", default: true, null: false
    t.string "rent_your_boat_title_main"
    t.string "rent_your_boat_strip_color"
    t.string "rent_your_boat_title_1"
    t.text "rent_your_boat_descr_1"
    t.string "rent_your_boat_title_2"
    t.text "rent_your_boat_descr_2"
    t.string "rent_your_boat_title_3"
    t.text "rent_your_boat_descr_3"
    t.string "rent_your_boat_title_4"
    t.text "rent_your_boat_descr_4"
    t.string "explain_settings_title_1"
    t.string "explain_settings_strip_color_1"
    t.text "explain_settings_descr_1"
    t.string "explain_settings_title_2"
    t.string "explain_settings_strip_color_2"
    t.text "explain_settings_descr_2"
    t.string "explain_settings_title_3"
    t.string "explain_settings_strip_color_3"
    t.text "explain_settings_descr_3"
    t.string "safety_settings_title_main"
    t.string "safety_settings_title_1"
    t.text "safety_settings_descr_1"
    t.string "safety_settings_title_2"
    t.text "safety_settings_descr_2"
    t.string "safety_settings_title_3"
    t.text "safety_settings_descr_3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "author_id"
    t.string "reportable_type"
    t.bigint "reportable_id"
    t.integer "reason"
    t.string "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_reports_on_author_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "trip_id"
    t.bigint "receiver_id"
    t.integer "status", default: 0
    t.integer "target"
    t.text "public_review"
    t.text "private_review"
    t.text "reply_review"
    t.datetime "reviewed_at"
    t.datetime "replied_at"
    t.integer "communication_grade", limit: 2
    t.integer "cleanliness_grade", limit: 2
    t.integer "boat_rules_grade", limit: 2
    t.integer "accuracy_grade", limit: 2
    t.integer "location_grade", limit: 2
    t.integer "check_in_grade", limit: 2
    t.integer "value_grade", limit: 2
    t.boolean "recommended", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "receiver_review_done", default: false
    t.decimal "avg_grade", precision: 3, scale: 2
    t.boolean "enabled", default: true, null: false
    t.index ["receiver_id"], name: "index_reviews_on_receiver_id"
    t.index ["sender_id"], name: "index_reviews_on_sender_id"
    t.index ["trip_id"], name: "index_reviews_on_trip_id"
  end

  create_table "season_rates", force: :cascade do |t|
    t.bigint "boat_id"
    t.string "offer_name"
    t.date "started_at"
    t.date "finished_at"
    t.integer "minimum_stay"
    t.decimal "per_half_day", precision: 8, scale: 2
    t.decimal "per_day", precision: 8, scale: 2
    t.decimal "per_night", precision: 8, scale: 2
    t.decimal "per_week", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["boat_id"], name: "index_season_rates_on_boat_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true
    t.index ["target_type", "target_id"], name: "index_settings_on_target_type_and_target_id"
  end

  create_table "stripe_accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "stripe_user_id"
    t.string "stripe_account_type"
    t.string "publishable_key"
    t.string "secret_key"
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "account_verified", default: false
    t.string "express_account_id"
    t.boolean "payout_ready", default: false
    t.index ["user_id"], name: "index_stripe_accounts_on_user_id"
  end

  create_table "travel_booking_blockings", force: :cascade do |t|
    t.bigint "boat_id"
    t.date "started_at", null: false
    t.date "finished_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rental_type", default: 0, null: false
    t.index ["boat_id"], name: "index_travel_booking_blockings_on_boat_id"
  end

  create_table "travel_bookings", force: :cascade do |t|
    t.bigint "trip_id"
    t.bigint "client_id"
    t.integer "status"
    t.integer "payment_process"
    t.integer "number_of_guests"
    t.integer "number_of_period"
    t.integer "per_price_cents"
    t.integer "seller_fee_cents"
    t.integer "client_fee_cents"
    t.integer "service_fee_cents"
    t.integer "earnings_cents"
    t.integer "subtotal_cents"
    t.integer "total_cents"
    t.string "currency"
    t.string "reservation_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cleaning_fee_cents", default: 0
    t.integer "skipper_fee_cents", default: 0
    t.index ["client_id"], name: "index_travel_bookings_on_client_id"
    t.index ["reservation_code"], name: "index_travel_bookings_on_reservation_code", unique: true
    t.index ["status"], name: "index_travel_bookings_on_status"
    t.index ["trip_id"], name: "index_travel_bookings_on_trip_id"
  end

  create_table "travel_customers", force: :cascade do |t|
    t.bigint "trip_id"
    t.bigint "client_id"
    t.integer "number_of_guests"
    t.integer "number_of_period"
    t.integer "per_price_cents"
    t.integer "seller_fee_cents"
    t.integer "client_fee_cents"
    t.integer "service_fee_cents"
    t.integer "earnings_cents"
    t.integer "subtotal_cents"
    t.integer "total_cents"
    t.string "currency"
    t.datetime "last_activity"
    t.datetime "left_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "seen_at", default: "1970-01-01 00:00:00"
    t.integer "cleaning_fee_cents", default: 0
    t.integer "skipper_fee_cents", default: 0
    t.index ["client_id"], name: "index_travel_customers_on_client_id"
    t.index ["last_activity"], name: "index_travel_customers_on_last_activity"
    t.index ["left_at"], name: "index_travel_customers_on_left_at"
    t.index ["seen_at"], name: "index_travel_customers_on_seen_at"
    t.index ["trip_id"], name: "index_travel_customers_on_trip_id"
  end

  create_table "travel_invoices", force: :cascade do |t|
    t.bigint "booking_id"
    t.string "client_number"
    t.string "seller_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_travel_invoices_on_booking_id"
    t.index ["client_number"], name: "index_travel_invoices_on_client_number", unique: true
    t.index ["seller_number"], name: "index_travel_invoices_on_seller_number", unique: true
  end

  create_table "travel_messages", force: :cascade do |t|
    t.bigint "trip_id"
    t.bigint "sender_id"
    t.integer "context", default: 0
    t.text "content"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context"], name: "index_travel_messages_on_context"
    t.index ["sender_id"], name: "index_travel_messages_on_sender_id"
    t.index ["trip_id"], name: "index_travel_messages_on_trip_id"
  end

  create_table "travel_payments", force: :cascade do |t|
    t.bigint "booking_id"
    t.integer "type_of"
    t.string "charge_id"
    t.string "balance_txn_id"
    t.string "transfer_id"
    t.integer "stripe_fee_cents"
    t.integer "per_price_cents"
    t.integer "seller_fee_cents"
    t.integer "client_fee_cents"
    t.integer "service_fee_cents"
    t.integer "earnings_cents"
    t.integer "subtotal_cents"
    t.integer "total_cents"
    t.integer "penalty_from_seller_cents"
    t.string "currency"
    t.string "source"
    t.integer "try_charge_count", default: 0
    t.datetime "captured_at"
    t.datetime "transferred_at"
    t.datetime "plan_charge_at"
    t.datetime "last_charge_fail_at"
    t.boolean "urgent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cleaning_fee_cents", default: 0
    t.integer "skipper_fee_cents", default: 0
    t.string "payment_intent_id"
    t.integer "intent_status"
    t.integer "refunded_cents"
    t.datetime "refunded_at"
    t.index ["booking_id"], name: "index_travel_payments_on_booking_id"
    t.index ["captured_at"], name: "index_travel_payments_on_captured_at"
    t.index ["plan_charge_at"], name: "index_travel_payments_on_plan_charge_at"
    t.index ["transferred_at"], name: "index_travel_payments_on_transferred_at"
    t.index ["type_of"], name: "index_travel_payments_on_type_of"
    t.index ["urgent"], name: "index_travel_payments_on_urgent"
  end

  create_table "travel_trip_cancellations", force: :cascade do |t|
    t.bigint "trip_id"
    t.integer "subject"
    t.text "reason"
    t.boolean "seller"
    t.integer "refunded_cents"
    t.integer "penalty_cents"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_penalty_excision_id"
    t.integer "canceler_id"
    t.index ["canceler_id"], name: "index_travel_trip_cancellations_on_canceler_id"
    t.index ["trip_id"], name: "index_travel_trip_cancellations_on_trip_id"
  end

  create_table "travel_trips", force: :cascade do |t|
    t.bigint "boat_id"
    t.bigint "seller_id"
    t.datetime "check_in"
    t.datetime "check_out"
    t.integer "status"
    t.integer "rental"
    t.integer "cancellation"
    t.integer "number_of_guests"
    t.integer "number_of_period"
    t.integer "max_guests"
    t.integer "min_guests"
    t.integer "per_price_cents"
    t.integer "seller_fee_cents"
    t.integer "client_fee_cents"
    t.integer "service_fee_cents"
    t.integer "earnings_cents"
    t.integer "subtotal_cents"
    t.integer "total_cents"
    t.integer "vat_fee_percents"
    t.string "currency"
    t.datetime "transfer_at"
    t.text "boat_hash"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "seller_seen_at", default: "1970-01-01 00:00:00"
    t.integer "cleaning_fee_cents", default: 0
    t.integer "skipper_fee_cents", default: 0
    t.boolean "skipper_included"
    t.index ["boat_id"], name: "index_travel_trips_on_boat_id"
    t.index ["check_in"], name: "index_travel_trips_on_check_in"
    t.index ["check_out"], name: "index_travel_trips_on_check_out"
    t.index ["rental"], name: "index_travel_trips_on_rental"
    t.index ["seller_id"], name: "index_travel_trips_on_seller_id"
    t.index ["seller_seen_at"], name: "index_travel_trips_on_seller_seen_at"
    t.index ["status"], name: "index_travel_trips_on_status"
    t.index ["transfer_at"], name: "index_travel_trips_on_transfer_at"
  end

  create_table "user_payouts", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "payoutable_id"
    t.string "payoutable_type"
    t.integer "payout_status"
    t.boolean "payout_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payoutable_type", "payoutable_id"], name: "index_user_payouts_on_payoutable_type_and_payoutable_id"
    t.index ["user_id"], name: "index_user_payouts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.string "phone_verification_code"
    t.datetime "phone_verification_code_sent_at"
    t.boolean "phone_verified", default: false, null: false
    t.string "auth_via"
    t.string "uid_facebook"
    t.string "image_url_facebook"
    t.string "uid_google_oauth2"
    t.string "image_url_google_oauth2"
    t.boolean "closed", default: false
    t.string "stripe_customer_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.date "birthday"
    t.string "language"
    t.string "currency"
    t.string "where_you_live"
    t.text "describe_yourself"
    t.datetime "blocked_at"
    t.string "display_name"
    t.decimal "avg_response_rate", precision: 5, scale: 2, default: "0.0"
    t.integer "avg_response_seconds", default: 0
    t.jsonb "facebook_data", default: {}, null: false
    t.jsonb "google_oauth2_data", default: {}, null: false
    t.string "nie"
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["auth_via"], name: "index_users_on_auth_via"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid_facebook"], name: "index_users_on_uid_facebook"
    t.index ["uid_google_oauth2"], name: "index_users_on_uid_google_oauth2"
  end

end
