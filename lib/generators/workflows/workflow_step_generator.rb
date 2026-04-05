# frozen_string_literal: true

require "rails/generators"

module Workflows
  class WorkflowStepGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    desc "Creates a workflow step model"

    def create_workflow_step
      template "workflow_step.rb.erb", "app/workflow_steps/#{file_path}_step.rb"
    end
  end
end
