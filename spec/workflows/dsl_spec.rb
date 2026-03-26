# frozen_string_literal: true

RSpec.describe Workflows::DSL do
  subject(:workflow) { workflow_one_class.new }

  let(:workflow_one_class) do
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

        step :five,
             type: "OneStep",
             depends_on: [:four]
      end

      def self.name
        "WorkflowOne"
      end
    end
  end

  let(:one_step_class) do
    Class.new(Workflows::WorkflowStep) do
      def self.name
        "OneStep"
      end
    end
  end

  let(:two_step_class) do
    Class.new(Workflows::WorkflowStep) do
      def self.name
        "TwoStep"
      end
    end
  end

  let(:three_step_class) do
    Class.new(Workflows::WorkflowStep) do
      def self.name
        "ThreeStep"
      end
    end
  end

  let(:four_step_class) do
    Class.new(Workflows::WorkflowStep) do
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
        .to change(Workflows::WorkflowStep, :count)
        .by(5)

      step_one, step_two, step_three, step_four, step_five = workflow.workflow_steps

      expect(step_one).to be_a one_step_class
      expect(step_one.name).to eq "one"

      expect(step_two).to be_a two_step_class
      expect(step_two.name).to eq "two"

      expect(step_three).to be_a three_step_class
      expect(step_three.name).to eq "three"

      expect(step_four).to be_a four_step_class
      expect(step_four.name).to eq "four"

      expect(step_five).to be_a one_step_class
      expect(step_five.name).to eq "five"
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
      step_one, step_two, step_three, step_four, step_five = abstract_workflow.abstract_workflow_steps

      expect(step_one).to be_a Workflows::AbstractStep
      expect(step_one.name).to eq :one
      expect(step_one.depends_on).to be_empty
      expect(step_one.type).to eq one_step_class

      expect(step_two).to be_a Workflows::AbstractStep
      expect(step_two.name).to eq :two
      expect(step_two.depends_on).to contain_exactly(:one)
      expect(step_two.type).to eq two_step_class

      expect(step_three).to be_a Workflows::AbstractStep
      expect(step_three.name).to eq :three
      expect(step_three.depends_on).to contain_exactly(:two)
      expect(step_three.type).to eq three_step_class

      expect(step_four).to be_a Workflows::AbstractStep
      expect(step_four.name).to eq :four
      expect(step_four.depends_on).to contain_exactly(:three)
      expect(step_four.type).to eq four_step_class

      expect(step_five).to be_a Workflows::AbstractStep
      expect(step_five.name).to eq :five
      expect(step_five.depends_on).to contain_exactly(:four)
      expect(step_five.type).to eq one_step_class
    end
  end
end
