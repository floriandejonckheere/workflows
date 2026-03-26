# frozen_string_literal: true

module Workflows
  class Workflow < Workflows.configuration.parent_model_class.constantize
    include DSL

    self.table_name = "workflows"

    STATES = [
      "pending",
      "processing",
      "completed",
      "failed",
    ].freeze

    has_many :workflow_steps,
             class_name: "Workflows::WorkflowStep",
             dependent: :destroy,
             inverse_of: :workflow

    validates :type,
              presence: true

    enum :state,
         STATES.index_by(&:itself),
         validate: true

    def all_workflow_steps_completed?
      workflow_steps.any? && workflow_steps.all? { |step| step.state == "completed" }
    end

    def any_workflow_step_failed?
      workflow_steps.any? { |step| step.state == "failed" }
    end
  end
end
