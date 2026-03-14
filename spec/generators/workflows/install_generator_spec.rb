# frozen_string_literal: true

require "rails/generators/testing/behavior"

require "generators/workflows/install_generator"

RSpec.describe Workflows::InstallGenerator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp/generators", __dir__)

  before { prepare_destination }
  after { rm_rf(destination_root) }

  describe "migration" do
    before { run_generator }

    it "creates the migration file" do
      migration = Dir.glob(File.join(destination_root, "db/migrate/*_create_workflow_tables.rb"))

      expect(migration).not_to be_empty
    end
  end

  describe "initializer" do
    before { run_generator }

    it "creates the initializer file" do
      expect(File).to exist(File.join(destination_root, "config/initializers/workflows.rb"))
    end
  end
end
