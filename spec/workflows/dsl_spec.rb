# frozen_string_literal: true

RSpec.describe Workflows::DSL do
  subject(:workflow) { my_workflow_class.new }

  let(:my_workflow_class) do
    Class.new do
      include Workflows::DSL

      workflow do
        step :one

        step :two,
             depends_on: [:one]

        step :three,
             depends_on: [:two]

        step :four,
             depends_on: [:three]
      end

      def self.name
        "MyWorkflow"
      end
    end
  end

  let(:one_step_class) do
    Class.new(Workflows::Step) do
      def self.name
        "OneStep"
      end
    end
  end

  let(:two_step_class) do
    Class.new(Workflows::Step) do
      def self.name
        "TwoStep"
      end
    end
  end

  let(:three_step_class) do
    Class.new(Workflows::Step) do
      def self.name
        "ThreeStep"
      end
    end
  end

  let(:four_step_class) do
    Class.new(Workflows::Step) do
      def self.name
        "FourStep"
      end
    end
  end

  describe "#step" do
    it "defines a workflow step" do
      step_one = workflow.steps.first

      expect(step_one).to be_a Workflows::DSL::Step
      expect(step_one.name).to eq :one
      expect(step_one.depends_on).to be_empty

      step_two = workflow.steps.second

      expect(step_two).to be_a Workflows::DSL::Step
      expect(step_two.name).to eq :two
      expect(step_two.depends_on).to contain_exactly(:one)

      step_three = workflow.steps.third

      expect(step_three).to be_a Workflows::DSL::Step
      expect(step_three.name).to eq :three
      expect(step_three.depends_on).to contain_exactly(:two)
    end
  end
end
