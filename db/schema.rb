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

ActiveRecord::Schema.define(version: 2019_11_18_132813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activation_codes", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.string "code", null: false
    t.integer "tries_count", default: 0, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_activation_codes_on_code"
    t.index ["expires_at"], name: "index_activation_codes_on_expires_at"
    t.index ["owner_id", "owner_type"], name: "index_activation_codes_on_owner"
  end

  create_table "admin_managed_resources", force: :cascade do |t|
    t.string "class_name", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_name", "action"], name: "admin_managed_resources_index", unique: true
  end

  create_table "admin_role_permissions", force: :cascade do |t|
    t.integer "admin_role_id", null: false
    t.integer "admin_managed_resource_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_managed_resource_id"], name: "index_admin_role_permissions_on_admin_managed_resource_id"
    t.index ["admin_role_id", "admin_managed_resource_id"], name: "admin_role_permissions_index", unique: true
    t.index ["admin_role_id"], name: "index_admin_role_permissions_on_admin_role_id"
  end

  create_table "admin_roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((id)::text) varchar_pattern_ops", name: "index_admin_roles_on_id_text"
    t.index "lower((display_name)::text) varchar_pattern_ops", name: "index_admin_roles_on_lowercase_display_name"
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_admin_roles_on_lowercase_name"
    t.index ["display_name"], name: "index_admin_roles_on_display_name"
    t.index ["name"], name: "index_admin_roles_on_name"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "thumbnail"
    t.integer "admin_role_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
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
    t.datetime "password_changed_at"
    t.string "unique_session_id", limit: 20
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_role_id"], name: "index_admin_users_on_admin_role_id"
    t.index ["confirmation_token"], name: "index_admin_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["expired_at"], name: "index_admin_users_on_expired_at"
    t.index ["last_activity_at"], name: "index_admin_users_on_last_activity_at"
    t.index ["password_changed_at"], name: "index_admin_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "app_settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.integer "data_type", default: 0
    t.string "description", limit: 4096
    t.boolean "is_client_accessible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_app_settings_on_key"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "beta_data_records", force: :cascade do |t|
    t.integer "sample_id", null: false
    t.decimal "secs_elapsed", precision: 10, scale: 4, null: false
    t.integer "qcm_1", null: false
    t.integer "qcm_2", null: false
    t.integer "qcm_3", null: false
    t.integer "qcm_4", null: false
    t.integer "qcm_5", null: false
    t.decimal "humidiy", precision: 10, scale: 4
    t.decimal "temp", precision: 10, scale: 4
    t.index ["sample_id"], name: "index_beta_data_records_on_sample_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "note"
    t.index ["name"], name: "index_brands_on_name"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_cards_on_name"
  end

  create_table "client_actions", force: :cascade do |t|
    t.string "name"
    t.string "required_linkable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_client_actions_on_lowercase_name"
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_notification_types_on_lowercase_name"
    t.index ["name"], name: "index_client_actions_on_name"
  end

  create_table "data_records", force: :cascade do |t|
    t.integer "sample_id", null: false
    t.decimal "secs_elapsed", precision: 10, scale: 4, null: false
    t.integer "qcm_1", null: false
    t.integer "qcm_2", null: false
    t.integer "qcm_3", null: false
    t.integer "qcm_4", null: false
    t.integer "qcm_5", null: false
    t.integer "qcm_6", null: false
    t.integer "qcm_7", null: false
    t.integer "humidiy"
    t.integer "temp"
    t.index ["sample_id"], name: "index_data_records_on_sample_id"
  end

  create_table "devices", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "device_token"
    t.integer "os_type"
    t.string "device_type"
    t.string "os_version"
    t.string "app_version"
    t.integer "failed_attempts", default: 0
    t.boolean "is_sandbox", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_token"], name: "index_devices_on_device_token"
    t.index ["owner_id", "owner_type"], name: "index_devices_on_owner"
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "name"
    t.jsonb "body_pattern", default: {}
    t.integer "client_action_id"
    t.boolean "send_push", default: false
    t.boolean "send_sms", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_action_id"], name: "index_notification_types_on_client_action_id"
    t.index ["name"], name: "index_notification_types_on_name"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "sender_id"
    t.string "sender_type"
    t.integer "receiver_id"
    t.string "receiver_type"
    t.integer "notification_type_id"
    t.string "body", limit: 4096
    t.integer "linkable_id"
    t.string "linkable_type"
    t.integer "delivery_status", default: 0
    t.boolean "is_visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linkable_id", "linkable_type"], name: "index_notifications_on_linkable"
    t.index ["notification_type_id"], name: "index_notifications_on_notification_type_id"
    t.index ["receiver_id", "receiver_type"], name: "index_notifications_on_receiver"
    t.index ["sender_id", "sender_type"], name: "index_notifications_on_sender"
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.string "password_salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "brand_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["name"], name: "index_products_on_name"
  end

  create_table "protocols", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
  end

  create_table "sample_tags", force: :cascade do |t|
    t.integer "sample_id", null: false
    t.integer "tag_id", null: false
    t.index ["sample_id"], name: "index_sample_tags_on_sample_id"
    t.index ["tag_id"], name: "index_sample_tags_on_tag_id"
  end

  create_table "sampler_types", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "samplers", force: :cascade do |t|
    t.integer "sampler_type_id", null: false
    t.string "name", null: false
  end

  create_table "samples", force: :cascade do |t|
    t.string "type", null: false
    t.integer "user_id"
    t.string "device"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_name", default: "", null: false
    t.integer "protocol_id"
    t.integer "sampler_id"
    t.integer "card_id"
    t.string "note"
    t.integer "product_id", null: false
    t.index ["type"], name: "index_samples_on_type"
    t.index ["user_id"], name: "index_samples_on_user_id"
  end

  create_table "symptom_categories", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "symptoms", force: :cascade do |t|
    t.bigint "symptom_category_id"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symptom_category_id"], name: "index_symptoms_on_symptom_category_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "treatments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_symptoms", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "symptom_id"
    t.integer "severity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symptom_id"], name: "index_user_symptoms_on_symptom_id"
    t.index ["user_id"], name: "index_user_symptoms_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "requires_local_auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token", null: false
    t.integer "status", default: 0, null: false
    t.integer "gender", default: 0, null: false
    t.datetime "last_activity_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number", null: false
    t.datetime "birth_date"
  end

  add_foreign_key "symptoms", "symptom_categories"
end
