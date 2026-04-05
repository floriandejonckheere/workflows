# frozen_string_literal: true

require "rails/generators"

module Workflows
  class WorkflowGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    desc "Creates a workflow model"

    argument :steps,
             type: :array,
             default: [],
             banner: "step_one step_two ..."

    def create_workflow
      template "workflow.rb.erb", "app/workflows/#{file_path}_workflow.rb"
    end

    def create_steps
      steps.each do |step|
        @workflow_class = class_name
        @step_class = step.camelize
        template "workflow_step_inline.rb.erb",
                 "app/workflow_steps/#{file_path}/#{step}_step.rb"
      end
    end
  end
end
