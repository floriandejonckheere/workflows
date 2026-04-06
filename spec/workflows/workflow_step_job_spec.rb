# frozen_string_literal: true

RSpec.describe Workflows::WorkflowStepJob do
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
             condition: :second?,
             depends_on: [:first]

        step :third,
             type: "Step",
             depends_on: [:second]

        step :fourth,
             type: "Step",
             condition: ->(fourth: true) { !fourth },
             depends_on: [:third]

        step :fifth,
             type: "Step",
             depends_on: [:fourth]
      end

      def second?
        ENV.fetch("SECOND", "0") == "0"
      end

      def self.name
        "Workflow"
      end
    end
  end

  let(:workflow) { create(:workflow, type: workflow_class.name) }
  let(:workflow_step) { workflow.workflow_steps.find_by(name: "first") }

  before do
    stub_const("Step", step_class)
    stub_const("Workflow", workflow_class)
  end

  ["completed", "failed"].each do |state|
    context "when the step is already #{state}" do
      before { workflow_step.update!(state:) }

      it "does not change the step state" do
        expect { job.perform(workflow, workflow_step) }
          .not_to(change { workflow_step.reload.state })
      end

      it "does not execute the step" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .not_to have_received(:call)
      end

      it "enqueues a workflow job" do
        expect { job.perform(workflow, workflow_step) }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow)
      end

      it "passes arguments to the workflow job" do
        expect { job.perform(workflow, workflow_step, "argument_one", argument: "two") }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow, "argument_one", argument: "two")
      end
    end
  end

  ["pending", "processing"].each do |initial_state|
    context "when the step is #{initial_state}" do
      before { workflow_step.update!(state: initial_state) }

      it "transitions to completed on success" do
        expect { job.perform(workflow, workflow_step) }
          .to change { workflow_step.reload.state }
          .from(initial_state).to("completed")

        expect(workflow_step.completed_at).to be_present
        expect(workflow_step.failed_at).to be_nil
      end

      it "transitions to failed on failure" do
        allow(workflow_step)
          .to receive(:call)
          .and_raise ArgumentError, "This is an error message"

        expect { expect { job.perform(workflow, workflow_step) }.to raise_error ArgumentError }
          .to change { workflow_step.reload.state }
          .from(initial_state).to("failed")

        expect(workflow_step.completed_at).to be_nil
        expect(workflow_step.failed_at).to be_present
        expect(workflow_step.error_class).to eq "ArgumentError"
        expect(workflow_step.error_message).to eq "This is an error message"
      end

      it "passes arguments to the step" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step, "argument_one", argument: "two")

        expect(workflow_step)
          .to have_received(:call)
          .with("argument_one", argument: "two")
      end

      it "enqueues a workflow job" do
        expect { job.perform(workflow, workflow_step) }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow)
      end

      it "passes arguments to the workflow job" do
        expect { job.perform(workflow, workflow_step, "argument_one", argument: "two") }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow, "argument_one", argument: "two")
      end
    end
  end

  context "when dependencies are not satisfied" do
    let(:workflow_step) { workflow.workflow_steps.find_by(name: "third") }

    it "does not execute the step" do
      allow(workflow_step)
        .to receive(:call)
        .and_call_original

      job.perform(workflow, workflow_step)

      expect(workflow_step)
        .not_to have_received(:call)
    end
  end

  context "when a dependency is skipped" do
    let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

    before { workflow.workflow_steps.find_by(name: "first").update!(state: "skipped") }

    it "executes the step" do
      ClimateControl.modify SECOND: "1" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .to have_received(:call)
      end
    end
  end

  context "when a condition is specified" do
    context "as a symbol" do
      let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

      before { workflow.workflow_steps.find_by(name: "first").update!(state: "completed") }

      it "skips the step when the skip condition is met" do
        ClimateControl.modify SECOND: "0" do
          expect { job.perform(workflow, workflow_step) }
            .to change { workflow_step.reload.state }
            .from("pending").to("skipped")

          expect(workflow_step.completed_at).to be_present
          expect(workflow_step.failed_at).to be_nil
        end
      end

      it "executes the step when the skip condition is not met" do
        ClimateControl.modify SECOND: "1" do
          allow(workflow_step)
            .to receive(:call)
            .and_call_original

          job.perform(workflow, workflow_step)

          expect(workflow_step).to have_received(:call)
        end
      end
    end

    context "as a proc" do
      let(:workflow_step) { workflow.workflow_steps.find_by(name: "fourth") }

      before { workflow.workflow_steps.find_by(name: "third").update!(state: "completed") }

      it "skips the step when the skip condition is met" do
        expect { job.perform(workflow, workflow_step, fourth: false) }
          .to change { workflow_step.reload.state }
          .from("pending").to("skipped")

        expect(workflow_step.completed_at).to be_present
        expect(workflow_step.failed_at).to be_nil
      end

      it "executes the step when the skip condition is not met" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step, fourth: true)

        expect(workflow_step)
          .to have_received(:call)
      end
    end
  end
end
