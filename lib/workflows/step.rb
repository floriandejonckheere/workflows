# frozen_string_literal: true

module Workflows
  class Step < Workflows.configuration.parent_model_class.constantize
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

    validates :class_name,
              presence: true

    enum :state,
         STATES.index_by(&:itself),
         validate: true

    before_validation :set_class_name,
                      on: :create

    private

    def set_class_name
      self.class_name ||= "#{name.to_s.camelize}Step"
    end
  end
end
