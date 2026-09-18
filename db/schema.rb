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

ActiveRecord::Schema[8.1].define(version: 2026_09_17_200001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "code_proposals", force: :cascade do |t|
    t.string "code", null: false
    t.integer "confidence", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.bigint "encounter_id", null: false
    t.text "evidence", default: "", null: false
    t.boolean "grounded", default: false, null: false
    t.string "kind", null: false
    t.string "modifiers", default: "", null: false
    t.integer "position", default: 0, null: false
    t.text "rationale", default: "", null: false
    t.datetime "reviewed_at"
    t.string "reviewed_by"
    t.string "source", null: false
    t.string "state", default: "proposed", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id", "kind", "code"], name: "index_code_proposals_on_encounter_id_and_kind_and_code", unique: true
    t.index ["encounter_id"], name: "index_code_proposals_on_encounter_id"
  end

  create_table "code_sets", force: :cascade do |t|
    t.boolean "billable", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.boolean "em", default: false, null: false
    t.string "keywords", default: "", null: false
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "code"], name: "index_code_sets_on_kind_and_code", unique: true
  end

  create_table "encounters", force: :cascade do |t|
    t.string "claim_number"
    t.string "coder_used"
    t.datetime "created_at", null: false
    t.date "date_of_service", null: false
    t.datetime "finalized_at"
    t.string "finalized_by"
    t.text "note", null: false
    t.string "patient_ref", null: false
    t.string "provider", null: false
    t.string "status", default: "new", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_number"], name: "index_encounters_on_claim_number", unique: true
    t.index ["status"], name: "index_encounters_on_status"
  end

  create_table "eval_cases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "gold_dx", default: [], null: false, array: true
    t.string "gold_px", default: [], null: false, array: true
    t.text "note", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "eval_runs", force: :cascade do |t|
    t.string "coder", null: false
    t.datetime "created_at", null: false
    t.jsonb "details", default: [], null: false
    t.decimal "f1", precision: 5, scale: 4, null: false
    t.integer "fn", null: false
    t.integer "fp", null: false
    t.decimal "grounded_pct", precision: 5, scale: 4, null: false
    t.integer "n_cases", null: false
    t.decimal "precision", precision: 5, scale: 4, null: false
    t.datetime "ran_at", null: false
    t.decimal "recall", precision: 5, scale: 4, null: false
    t.integer "tp", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor", null: false
    t.datetime "created_at", null: false
    t.bigint "encounter_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.index ["encounter_id", "created_at"], name: "index_events_on_encounter_id_and_created_at"
    t.index ["encounter_id"], name: "index_events_on_encounter_id"
  end

  create_table "excludes1_rules", force: :cascade do |t|
    t.string "code_a", null: false
    t.string "code_b", null: false
    t.datetime "created_at", null: false
    t.string "note", null: false
    t.datetime "updated_at", null: false
    t.index ["code_a", "code_b"], name: "index_excludes1_rules_on_code_a_and_code_b", unique: true
  end

  add_foreign_key "code_proposals", "encounters"
  add_foreign_key "events", "encounters"
end
