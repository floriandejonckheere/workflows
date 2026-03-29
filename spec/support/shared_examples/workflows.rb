# frozen_string_literal: true

RSpec.shared_context "workflows" do # rubocop:disable RSpec/ContextWording
  ##
  # Dependency graph:
  #
  # five
  # └── four
  #     └── three
  #         └── two
  #             └── one
  #
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

  ##
  # Dependency graph:
  #
  # nested/one
  #
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

  ##
  # Dependency graph:
  #
  # four
  # ├── three
  # │   └── one
  # └── two
  #
  let(:workflow_three_class) do
    Class.new(Workflows::Workflow) do
      include Workflows::DSL::Workflow

      workflow do
        step :one
        step :two
        step :three, depends_on: [:one]
        step :four, depends_on: [:two, :three]
      end

      def self.name
        "WorkflowThree"
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

    stub_const("WorkflowOne", workflow_one_class)
    stub_const("WorkflowTwo", workflow_two_class)
    stub_const("WorkflowThree", workflow_three_class)
  end
end
