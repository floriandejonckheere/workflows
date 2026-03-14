# frozen_string_literal: true

RSpec.describe Workflows::Configuration do
  subject(:configuration) { described_class.new }

  describe "#parent_model_class. #parent_model_class=" do
    it "has a default" do
      expect(configuration.parent_model_class).to eq "ActiveRecord::Base"
    end

    it "gets and sets parent model class" do
      configuration.parent_model_class = "MyClass"

      expect(configuration.parent_model_class).to eq "MyClass"
    end
  end
end
