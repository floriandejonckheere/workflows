# frozen_string_literal: true

module Workflows
  module DSL
    extend ActiveSupport::Concern

    included do
      class_attribute :abstract_workflow,
                      default: AbstractWorkflow.new

      def self.inherited(subclass)
        super

        subclass.abstract_workflow = AbstractWorkflow.new
      end

      after_create :create_workflow_steps

      def create_workflow_steps
        abstract_workflow.abstract_workflow_steps.each do |abstract_step|
          abstract_workflow_steps.create!(
            name: abstract_step.name,
            type: abstract_step.class_name,
          )
        end
      end
    end

    class_methods do
      def workflow
        yield self
      end

      def step(name, depends_on: [], class_name: nil)
        abstract_workflow.abstract_workflow_steps << AbstractStep.new(
          name,
          depends_on:,
          class_name:,
        )
      end
    end
  end
end
