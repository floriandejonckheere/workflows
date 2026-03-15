# frozen_string_literal: true

module Workflows
  class Step < Workflows.configuration.parent_model_class.constantize
    self.table_name = "workflow_steps"

    STATES = [
      "pending",
      "processing",
      "completed",
      "failed",
    ].freeze

    belongs_to :workflow,
               optional: false,
               class_name: "Workflows::Workflow"

    validates :name,
              presence: true,
              uniqueness: { scope: :workflow_id }

    enum :state,
         STATES.index_by(&:itself),
         validate: true
  end
end
