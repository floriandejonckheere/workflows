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

ActiveRecord::Schema[8.1].define(version: 2026_03_14_144617) do
  create_table "workflow_steps", force: :cascade do |t|
    t.string "class_name", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "depends_on", default: "[]", null: false
    t.string "error_class"
    t.text "error_message"
    t.datetime "failed_at"
    t.string "name", null: false
    t.string "state", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "workflow_id", null: false
    t.index ["workflow_id", "name"], name: "index_workflow_steps_on_workflow_id_and_name", unique: true
    t.index ["workflow_id"], name: "index_workflow_steps_on_workflow_id"
  end

  create_table "workflows", force: :cascade do |t|
    t.string "class_name", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "failed_at"
    t.string "name", null: false
    t.string "state", default: "pending", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "workflow_steps", "workflows", on_delete: :cascade
end
