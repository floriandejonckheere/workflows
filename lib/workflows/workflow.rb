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

    has_many :steps,
             class_name: "Workflows::Step",
             dependent: :destroy,
             inverse_of: :workflow

    validates :name,
              presence: true

    validates :class_name,
              presence: true

    enum :state,
         STATES.index_by(&:itself),
         validate: true

    def all_steps_completed?
      steps.any? && steps.all? { |step| step.state == "completed" }
    end

    def any_step_failed?
      steps.any? { |step| step.state == "failed" }
    end
  end
end
