# frozen_string_literal: true

module Workflows
  module DSL
    module Workflow
      extend ActiveSupport::Concern

      included do
        class_attribute :abstract_workflow

        def self.inherited(subclass)
          super

          subclass.abstract_workflow = nil
        end

        after_create :create_workflow_steps

        def create_workflow_steps
          abstract_workflow&.abstract_workflow_steps&.each do |abstract_workflow_step|
            workflow_steps.create!(
              name: abstract_workflow_step.name,
              type: abstract_workflow_step.type,
            )
          end
        end
      end

      class_methods do
        def workflow(namespace = nil)
          yield self.abstract_workflow = AbstractWorkflow.new(namespace:)
        end

        def step(name, depends_on: [], type: nil)
          abstract_workflow.abstract_workflow_steps << AbstractWorkflowStep.new(
            name,
            depends_on:,
            type:,
            namespace: abstract_workflow.namespace,
          )
        end
      end
    end
  end
end
