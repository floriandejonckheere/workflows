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

  describe "without steps" do
    describe "without namespace" do
      before { run_generator ["onboarding"] }

      it "creates the workflow file" do
        expect(File).to exist(File.join(destination_root, "app/workflows/onboarding_workflow.rb"))
      end

      it "defines the correct class" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding_workflow.rb")))
          .to include("class OnboardingWorkflow < Workflows::Workflow")
      end

      it "includes the workflow namespace" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding_workflow.rb")))
          .to include("workflow :onboarding do")
      end

      it "includes a placeholder in the workflow block" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding_workflow.rb")))
          .to include("# ...")
      end
    end

    describe "namespaced" do
      before { run_generator ["onboarding/enrollment"] }

      it "creates the workflow file" do
        expect(File).to exist(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb"))
      end

      it "defines the correct class" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb")))
          .to include("class Onboarding::EnrollmentWorkflow < Workflows::Workflow")
      end

      it "includes the workflow namespace" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb")))
          .to include("workflow :\"onboarding/enrollment\" do")
      end
    end
  end

  describe "with steps" do
    describe "without namespace" do
      before { run_generator ["thumbnail_generation", "validate_image", "extract_metadata"] }

      it "creates the workflow file" do
        expect(File).to exist(File.join(destination_root, "app/workflows/thumbnail_generation_workflow.rb"))
      end

      it "includes the workflow namespace" do
        expect(File.read(File.join(destination_root, "app/workflows/thumbnail_generation_workflow.rb")))
          .to include("workflow :thumbnail_generation do")
      end

      it "includes step declarations in the workflow block" do
        content = File.read(File.join(destination_root, "app/workflows/thumbnail_generation_workflow.rb"))

        expect(content).to include("step :validate_image")
        expect(content).to include("step :extract_metadata")
      end

      it "creates the step files" do
        expect(File).to exist(File.join(destination_root, "app/workflow_steps/thumbnail_generation/validate_image_step.rb"))
        expect(File).to exist(File.join(destination_root, "app/workflow_steps/thumbnail_generation/extract_metadata_step.rb"))
      end

      it "defines the correct step classes" do
        content = File.read(File.join(destination_root, "app/workflow_steps/thumbnail_generation/validate_image_step.rb"))

        expect(content).to include("module ThumbnailGeneration")
        expect(content).to include("class ValidateImageStep < Workflows::WorkflowStep")
      end
    end

    describe "namespaced" do
      before { run_generator ["onboarding/enrollment", "register", "subscribe"] }

      it "creates the workflow file" do
        expect(File).to exist(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb"))
      end

      it "defines the correct class" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb")))
          .to include("class Onboarding::EnrollmentWorkflow < Workflows::Workflow")
      end

      it "includes the workflow namespace" do
        expect(File.read(File.join(destination_root, "app/workflows/onboarding/enrollment_workflow.rb")))
          .to include("workflow :\"onboarding/enrollment\" do")
      end

      it "creates the step files" do
        expect(File).to exist(File.join(destination_root, "app/workflow_steps/onboarding/enrollment/register_step.rb"))
        expect(File).to exist(File.join(destination_root, "app/workflow_steps/onboarding/enrollment/subscribe_step.rb"))
      end

      it "defines the correct step classes" do
        content = File.read(File.join(destination_root, "app/workflow_steps/onboarding/enrollment/register_step.rb"))

        expect(content).to include("module Onboarding::Enrollment")
        expect(content).to include("class RegisterStep < Workflows::WorkflowStep")
      end
    end
  end
end
