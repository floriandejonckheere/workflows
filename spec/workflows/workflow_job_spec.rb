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

  describe "state transitions" do
    context "when the workflow is pending" do
      let(:workflow) { create(:workflow, type: workflow_class.name, state: "pending") }

      it "changes the workflow state to processing" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("pending").to("processing")
      end

      context "when any workflow step is failed" do
        it "changes the workflow state to failed" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
          workflow.workflow_steps.find_by(name: "second").update!(state: "failed")

          expect { job.perform(workflow) }
            .to change { workflow.reload.state }
            .from("pending").to("failed")

          expect(workflow.completed_at).to be_nil
          expect(workflow.failed_at).to be_present
        end
      end

      context "when all workflow steps are completed or skipped" do
        it "changes the workflow state to completed" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
          workflow.workflow_steps.find_by(name: "second").update!(state: "skipped")
          workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

          expect { job.perform(workflow) }
            .to change { workflow.reload.state }
            .from("pending").to("completed")

          expect(workflow.completed_at).to be_present
          expect(workflow.failed_at).to be_nil
        end
      end
    end

    context "when the workflow is processing" do
      let(:workflow) { create(:workflow, type: workflow_class.name, state: "processing") }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end

      context "when any workflow step is failed" do
        it "changes the workflow state to failed" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
          workflow.workflow_steps.find_by(name: "second").update!(state: "failed")

          expect { job.perform(workflow) }
            .to change { workflow.reload.state }
            .from("processing").to("failed")

          expect(workflow.completed_at).to be_nil
          expect(workflow.failed_at).to be_present
        end
      end

      context "when all workflow steps are completed or skipped" do
        it "changes the workflow state to completed" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
          workflow.workflow_steps.find_by(name: "second").update!(state: "skipped")
          workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

          expect { job.perform(workflow) }
            .to change { workflow.reload.state }
            .from("processing").to("completed")

          expect(workflow.completed_at).to be_present
          expect(workflow.failed_at).to be_nil
        end
      end
    end

    context "when the workflow is completed" do
      let(:workflow) { create(:workflow, type: workflow_class.name, state: "completed") }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end

    context "when the workflow is failed" do
      let(:workflow) { create(:workflow, type: workflow_class.name, state: "failed") }

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

  describe "job scheduling" do
    it "enqueues pending workflow step jobs with all dependencies completed" do
      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "first"))

      workflow.workflow_steps.find_by(name: "first").update! state: "completed"

      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "second"))

      workflow.workflow_steps.find_by(name: "second").update! state: "completed"

      expect { job.perform(workflow) }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "third"))
    end

    it "passes arguments to workflow step jobs" do
      expect { job.perform(workflow, "argument_one", argument: "two") }
        .to have_enqueued_job(Workflows::WorkflowStepJob)
        .exactly(:once)
        .with(workflow, workflow.workflow_steps.find_by(name: "first"), "argument_one", argument: "two")
    end

    context "when some workflow steps are failed" do
      it "enqueues pending workflow step jobs with all dependencies completed" do
        workflow.workflow_steps.find_by(name: "first").update!(state: "failed")

        expect { job.perform(workflow) }
          .not_to have_enqueued_job(Workflows::WorkflowStepJob)
      end
    end

    context "when some workflow steps are completed or skipped" do
      it "enqueues pending workflow step jobs with all dependencies completed" do
        workflow.workflow_steps.find_by(name: "first").update!(state: "skipped")

        expect { job.perform(workflow) }
          .to have_enqueued_job(Workflows::WorkflowStepJob)
          .exactly(:once)
          .with(workflow, workflow.workflow_steps.find_by(name: "second"))

        workflow.workflow_steps.find_by(name: "second").update!(state: "completed")

        expect { job.perform(workflow) }
          .to have_enqueued_job(Workflows::WorkflowStepJob)
          .exactly(:once)
          .with(workflow, workflow.workflow_steps.find_by(name: "third"))
      end
    end
  end
end
