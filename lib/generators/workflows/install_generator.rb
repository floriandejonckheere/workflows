# frozen_string_literal: true

require "rails/generators"

module Workflows
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    desc "Creates the workflows initializer, migrations, and models."

    def copy_initializer
      template "workflows.rb", "config/initializers/workflows.rb"
    end
  end
end
