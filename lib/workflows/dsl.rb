# frozen_string_literal: true

module Workflows
  module DSL
    extend ActiveSupport::Concern

    included do
      class_attribute :abstract_workflow,
                      default: AbstractWorkflow.new
    end

    class_methods do
      def workflow
        yield self
      end

      def step(name, depends_on: [])
        abstract_workflow.steps << AbstractStep.new(
          name,
          depends_on:,
        )
      end
    end
  end
end
