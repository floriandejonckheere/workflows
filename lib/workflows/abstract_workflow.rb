# frozen_string_literal: true

module Workflows
  class AbstractWorkflow
    attr_reader :abstract_workflow_steps,
                :namespace

    def initialize(abstract_workflow_steps: [], namespace: nil)
      @abstract_workflow_steps = abstract_workflow_steps
      @namespace = namespace
    end

    def inspect
      "#<Workflows::AbstractWorkflow steps=[#{abstract_workflow_steps.map(&:name).join(', ')}]>"
    end
  end
end
