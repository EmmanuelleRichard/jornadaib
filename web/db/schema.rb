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

ActiveRecord::Schema.define(version: 20151011194128) do

  create_table "produtos", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.text     "description",            limit: 16777215
    t.string   "picture_file_name",      limit: 255
    t.string   "picture_content_type",   limit: 255
    t.integer  "picture_file_size",      limit: 4
    t.datetime "picture_updated_at"
    t.integer  "negocio_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "referencia",             limit: 255
    t.integer  "categoria_id",           limit: 4
    t.integer  "tipomedida_id",          limit: 4
    t.float    "preco",                  limit: 24
    t.float    "precopromocional",       limit: 24
    t.text     "especificacoes",         limit: 65535
    t.integer  "codigo",                 limit: 4
    t.boolean  "exibirmensagemimgilust"
    t.boolean  "fracaomeia"
    t.boolean  "disponivel"
  end

  add_index "produtos", ["categoria_id"], name: "index_produtos_on_categoria_id", using: :btree
  add_index "produtos", ["codigo"], name: "index_produtos_on_codigo", using: :btree
  add_index "produtos", ["negocio_id"], name: "index_produtos_on_negocio_id", using: :btree

  create_table "sexos", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "tipousuarios", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trabalhos", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "turma",         limit: 255
    t.string   "coordenadores", limit: 255
    t.text     "componentes",   limit: 65535
    t.string   "local",         limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                  limit: 255,                   null: false
    t.string   "email",                  limit: 255,                   null: false
    t.string   "crypted_password",       limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "persistence_token",      limit: 255
    t.string   "perishable_token",       limit: 255
    t.boolean  "status",                               default: false
    t.string   "nome",                   limit: 255
    t.string   "telefone1",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "login_count",            limit: 4,     default: 0
    t.integer  "failed_login_count",     limit: 4,     default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",       limit: 255
    t.string   "last_login_ip",          limit: 255
    t.boolean  "admin"
    t.string   "picture_file_name",      limit: 255
    t.string   "picture_content_type",   limit: 255
    t.integer  "picture_file_size",      limit: 4
    t.datetime "picture_updated_at"
    t.string   "codigo",                 limit: 255
    t.string   "single_access_token",    limit: 255
    t.integer  "tipousuario_id",         limit: 4
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,     default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "authentication_token",   limit: 255
    t.integer  "sexo_id",                limit: 4
    t.date     "datanascimento"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "facebook_token",         limit: 255
    t.datetime "facebook_expires_at"
    t.text     "tokens",                 limit: 65535
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "login", unique: true, using: :btree
  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
