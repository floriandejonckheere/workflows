# frozen_string_literal: true

require "rails/generators"

module Workflows
  class WorkflowGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    desc "Creates a workflow model"

    def create_workflow
      template "workflow.rb.erb", "app/workflows/#{file_name}_workflow.rb"
    end
  end
end
