# frozen_string_literal: true

require "rails/generators"

module Workflows
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    desc "Creates the workflows initializer, migrations, and models."

    def copy_migration
      migration_template "create_workflow_tables.rb", "db/migrate/create_workflow_tables.rb"
    end

    def copy_initializer
      template "workflows.rb", "config/initializers/workflows.rb"
    end

    def self.next_migration_number(_dirname)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end
  end
end
