# frozen_string_literal: true

module Workflows
  class AbstractWorkflow
    attr_reader :abstract_workflow_steps

    def initialize(abstract_workflow_steps: [])
      @abstract_workflow_steps = abstract_workflow_steps
    end
  end
end
