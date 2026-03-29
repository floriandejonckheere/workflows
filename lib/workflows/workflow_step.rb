# frozen_string_literal: true

module Workflows
  class WorkflowStep < Workflows.configuration.parent_model_class.constantize
    self.table_name = "workflow_steps"

    STATES = [
      "pending",
      "enqueued",
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

    validates :type,
              presence: true

    enum :state,
         STATES.index_by(&:itself),
         validate: true

    def abstract_workflow_step
      workflow
        .abstract_workflow
        .abstract_workflow_steps
        .fetch(name.to_sym)
    end
  end
end
