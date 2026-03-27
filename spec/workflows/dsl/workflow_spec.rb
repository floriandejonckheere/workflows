# frozen_string_literal: true

RSpec.describe Workflows::DSL::Workflow do
  subject(:workflow) { workflow_one_class.new }

  let(:workflow_one_class) do
    Class.new(Workflows::Workflow) do
      include Workflows::DSL::Workflow

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

  let(:workflow_two_class) do
    Class.new(Workflows::Workflow) do
      include Workflows::DSL

      workflow :nested do
        step :one
      end

      def self.name
        "WorkflowTwo"
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

  let(:nested_one_step_class) do
    Class.new(Workflows::WorkflowStep) do
      def self.name
        "Nested::OneStep"
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
    stub_const("Nested::OneStep", nested_one_step_class)
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
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow { nil }

      expect(klass.abstract_workflow).to be_a Workflows::AbstractWorkflow
    end

    it "defines an abstract workflow with a namespace" do
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow(:namespace) { nil }

      expect(klass.abstract_workflow.namespace).to eq :namespace
    end

    it "overrides an existing workflow" do
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow { nil }

      abstract_workflow = klass.abstract_workflow

      klass.workflow { nil }

      expect(klass.abstract_workflow).not_to eq abstract_workflow
    end
  end

  describe "#step" do
    it "defines an abstract workflow step" do
      abstract_workflow = workflow.abstract_workflow
      step_one, step_two, step_three, step_four, step_five = abstract_workflow.abstract_workflow_steps

      expect(step_one).to be_a Workflows::AbstractWorkflowStep
      expect(step_one.name).to eq :one
      expect(step_one.depends_on).to be_empty
      expect(step_one.type).to eq one_step_class

      expect(step_two).to be_a Workflows::AbstractWorkflowStep
      expect(step_two.name).to eq :two
      expect(step_two.depends_on).to contain_exactly(:one)
      expect(step_two.type).to eq two_step_class

      expect(step_three).to be_a Workflows::AbstractWorkflowStep
      expect(step_three.name).to eq :three
      expect(step_three.depends_on).to contain_exactly(:two)
      expect(step_three.type).to eq three_step_class

      expect(step_four).to be_a Workflows::AbstractWorkflowStep
      expect(step_four.name).to eq :four
      expect(step_four.depends_on).to contain_exactly(:three)
      expect(step_four.type).to eq four_step_class

      expect(step_five).to be_a Workflows::AbstractWorkflowStep
      expect(step_five.name).to eq :five
      expect(step_five.depends_on).to contain_exactly(:four)
      expect(step_five.type).to eq one_step_class
    end
  end
end
