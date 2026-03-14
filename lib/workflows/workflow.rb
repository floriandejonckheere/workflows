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
             class_name: "Workflows::Step"

    enum :state,
         STATES.index_by(&:itself),
         validate: true
  end
end
