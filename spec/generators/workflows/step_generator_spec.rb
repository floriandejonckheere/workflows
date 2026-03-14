# frozen_string_literal: true

require "rails/generators/testing/behavior"

require "generators/workflows/step_generator"

RSpec.describe Workflows::StepGenerator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp/generators", __dir__)

  before { prepare_destination }
  after { rm_rf(destination_root) }

  describe "model" do
    before { run_generator ["Onboarding::Welcome"] }

    it "creates the model file" do
      expect(File).to exist(File.join(destination_root, "app/workflows/onboarding/welcome_step.rb"))
    end

    it "defines the correct class" do
      expect(File.read(File.join(destination_root, "app/workflows/onboarding/welcome_step.rb")))
        .to include("class Onboarding::WelcomeStep < Workflows::Step")
    end
  end
end
