# frozen_string_literal: true

module Workflows
  class AbstractWorkflow
    attr_reader :steps

    def initialize(steps: [])
      @steps = steps
    end
  end
end
