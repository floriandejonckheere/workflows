# frozen_string_literal: true

RSpec.describe Workflows::DSL do
  subject(:workflow) { example_workflow_class.new }

  let(:example_workflow_class) do
    Class.new(Workflows::Workflow) do
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
        "ExampleWorkflow"
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

  before do
    stub_const("OneStep", one_step_class)
    stub_const("TwoStep", two_step_class)
    stub_const("ThreeStep", three_step_class)
    stub_const("FourStep", four_step_class)
  end

  describe "callbacks" do
    it "creates workflow steps after creation" do
      expect { workflow.save! }
        .to change(Workflows::Step, :count)
        .by(4)

      expect(workflow.steps.pluck(:type))
        .to eq ["OneStep", "TwoStep", "ThreeStep", "FourStep"]
    end
  end

  describe "#workflow" do
    it "defines an abstract workflow" do
      abstract_workflow = workflow.abstract_workflow

      expect(abstract_workflow).to be_a Workflows::AbstractWorkflow
    end
  end

  describe "#step" do
    it "defines an abstract workflow step" do
      abstract_workflow = workflow.abstract_workflow
      step_one = abstract_workflow.steps.first

      expect(step_one).to be_a Workflows::AbstractStep
      expect(step_one.name).to eq :one
      expect(step_one.depends_on).to be_empty

      step_two = abstract_workflow.steps.second

      expect(step_two).to be_a Workflows::AbstractStep
      expect(step_two.name).to eq :two
      expect(step_two.depends_on).to contain_exactly(:one)

      step_three = abstract_workflow.steps.third

      expect(step_three).to be_a Workflows::AbstractStep
      expect(step_three.name).to eq :three
      expect(step_three.depends_on).to contain_exactly(:two)
    end
  end
end
