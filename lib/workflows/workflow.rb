# frozen_string_literal: true

module Workflows
  class Workflow < Workflows.configuration.parent_model_class.constantize
    has_many :steps,
             class_name: "Workflows::Step"
  end
end
