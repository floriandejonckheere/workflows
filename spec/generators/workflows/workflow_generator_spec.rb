# frozen_string_literal: true

require "rails/generators/testing/behavior"

require "generators/workflows/workflow_generator"

RSpec.describe Workflows::WorkflowGenerator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp/generators", __dir__)

  before { prepare_destination }
  after { rm_rf(destination_root) }

  describe "model" do
    before { run_generator ["onboarding"] }

    it "creates the model file" do
      expect(File).to exist(File.join(destination_root, "app/workflows/onboarding_workflow.rb"))
    end

    it "defines the correct class" do
      expect(File.read(File.join(destination_root, "app/workflows/onboarding_workflow.rb")))
        .to include("class OnboardingWorkflow < Workflows::Workflow")
    end
  end
end
