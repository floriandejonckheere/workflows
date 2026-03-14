# frozen_string_literal: true

module Workflows
  class Step < Workflows.configuration.parent_model_class.constantize
    belongs_to :workflow,
               class_name: "Workflows::Workflow"
  end
end
