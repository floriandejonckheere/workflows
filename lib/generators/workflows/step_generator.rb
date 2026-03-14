# frozen_string_literal: true

require "rails/generators"

module Workflows
  class StepGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    desc "Creates a workflow step model"

    def create_workflow
      template "step.rb.erb", "app/workflows/#{file_path}_step.rb"
    end
  end
end
