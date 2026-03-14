# frozen_string_literal: true

class CreateWorkflowTables < ActiveRecord::Migration[7.0]
  def change
    create_table :workflows do |t|
      t.string :type, null: false
      t.string :state, null: false, default: "pending"
      t.datetime :completed_at
      t.datetime :failed_at

      t.timestamps
    end

    create_table :workflow_steps do |t|
      t.string :type, null: false
      t.string :state, null: false, default: "pending"
      t.datetime :completed_at
      t.datetime :failed_at

      t.references :workflow, null: false, foreign_key: { on_delete: :cascade }, index: true

      t.string :error_class
      t.text :error_message

      t.timestamps
    end
  end
end
