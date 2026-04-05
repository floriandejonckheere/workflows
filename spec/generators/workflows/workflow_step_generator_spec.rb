# frozen_string_literal: true

require "rails/generators/testing/behavior"

require "generators/workflows/workflow_step_generator"

RSpec.describe Workflows::WorkflowStepGenerator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp/generators", __dir__)

  before { prepare_destination }
  after { rm_rf(destination_root) }

  describe "without namespace" do
    before { run_generator ["register"] }

    it "creates the model file" do
      expect(File).to exist(File.join(destination_root, "app/workflow_steps/register_step.rb"))
    end

    it "defines the correct class" do
      content = File.read(File.join(destination_root, "app/workflow_steps/register_step.rb"))

      expect(content).to include("class RegisterStep < Workflows::WorkflowStep")
      expect(content).not_to include("module")
    end
  end

  describe "namespaced" do
    before { run_generator ["onboarding/register"] }

    it "creates the model file" do
      expect(File).to exist(File.join(destination_root, "app/workflow_steps/onboarding/register_step.rb"))
    end

    it "defines the correct class" do
      content = File.read(File.join(destination_root, "app/workflow_steps/onboarding/register_step.rb"))

      expect(content).to include("module Onboarding")
      expect(content).to include("class RegisterStep < Workflows::WorkflowStep")
    end
  end
end
