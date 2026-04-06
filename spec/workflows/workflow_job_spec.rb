# frozen_string_literal: true

RSpec.describe Workflows::WorkflowJob do
  subject(:job) { described_class.new }

  let(:step_class) do
    Class.new(Workflows::WorkflowStep) do
      def call(...); end

      def self.name
        "Step"
      end
    end
  end

  let(:workflow_class) do
    Class.new(Workflows::Workflow) do
      workflow do
        step :first,
             type: "Step"

        step :second,
             type: "Step",
             depends_on: [:first]

        step :third,
             type: "Step",
             depends_on: [:second]
      end

      def self.name
        "Workflow"
      end
    end
  end

  let(:workflow) { create(:workflow, type: workflow_class.name) }

  before do
    stub_const("Step", step_class)
    stub_const("Workflow", workflow_class)
  end

  ["completed", "failed"].each do |state|
    context "when the workflow is already #{state}" do
      let(:workflow) { create(:workflow, type: workflow_class.name, state:) }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end
  end

  shared_examples "terminal state transitions" do |state|
    context "when a step has failed" do
      before do
        workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
        workflow.workflow_steps.find_by(name: "second").update!(state: "failed")
      end

      it "transitions to failed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from(state).to("failed")

        expect(workflow.completed_at).to be_nil
        expect(workflow.failed_at).to be_present
      end
    end

    context "when all steps are completed or skipped" do
      before do
        workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
        workflow.workflow_steps.find_by(name: "second").update!(state: "skipped")
        workflow.workflow_steps.find_by(name: "third").update!(state: "completed")
      end

      it "transitions to completed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from(state).to("completed")

        expect(workflow.completed_at).to be_present
        expect(workflow.failed_at).to be_nil
      end
    end
  end

  context "when the workflow is pending" do
    let(:workflow) { create(:workflow, type: workflow_class.name, state: "pending") }

    it "transitions to processing" do
      expect { job.perform(workflow) }
        .to change { workflow.reload.state }
        .from("pending").to("processing")
    end

    it_behaves_like "terminal state transitions", "pending"
  end

  context "when the workflow is processing" do
    let(:workflow) { create(:workflow, type: workflow_class.name, state: "processing") }

    it "does not change the workflow state" do
      expect { job.perform(workflow) }
        .not_to(change { workflow.reload.state })
    end

    it_behaves_like "terminal state transitions", "processing"
  end

  describe "job scheduling" do
    it "enqueues the step whose dependencies are satisfied" do
      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "first"))
    end

    it "enqueues the next step once its dependency is satisfied" do
      workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "second"))
    end

    it "passes arguments to step jobs" do
      expect { job.perform(workflow, "argument_one", argument: "two") }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "first"), "argument_one", argument: "two")
    end

    it "does not enqueue step jobs when a step has failed" do
      workflow.workflow_steps.find_by(name: "first").update!(state: "failed")

      expect { job.perform(workflow) }
        .not_to have_enqueued_job(Workflows::WorkflowStepJob)
    end

    it "treats skipped steps as satisfied dependencies" do
      workflow.workflow_steps.find_by(name: "first").update!(state: "skipped")

      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "second"))
    end
  end
end
