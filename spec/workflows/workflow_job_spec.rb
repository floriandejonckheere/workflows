# frozen_string_literal: true

RSpec.describe Workflows::WorkflowJob do
  subject(:job) { described_class.new }

  let(:workflow) { create(:workflow, type: workflow_three_class.name) }

  include_context "workflows"

  describe "#perform" do
    context "when the workflow is pending" do
      it "changes the workflow state to processing" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("pending").to("processing")
      end

      it "enqueues workflow step jobs" do
        expect { job.perform(workflow) }
          .to have_enqueued_job(Workflows::WorkflowStepJob)
          .exactly(:once)
          .with(workflow, workflow.workflow_steps.find_by(name: "one"))
      end

      it "passes arguments to workflow step jobs" do
        expect { job.perform(workflow, "argument_one", argument: "two") }
          .to have_enqueued_job(Workflows::WorkflowStepJob)
          .exactly(:once)
          .with(workflow, workflow.workflow_steps.find_by(name: "one"), "argument_one", argument: "two")
      end
    end

    context "when the workflow is processing" do
      before { workflow.update!(state: "processing") }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end
    end

    context "when the workflow is already completed" do
      let(:workflow) { create(:workflow, :completed, type: workflow_three_class.name) }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end

    context "when the workflow is already failed" do
      let(:workflow) { create(:workflow, :failed, type: workflow_three_class.name) }

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end

    context "when at least one step has failed" do
      before { workflow.workflow_steps.find_by(name: "two").update!(state: "failed") }

      it "changes the workflow state to failed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("pending").to("failed")

        workflow.reload

        expect(workflow.completed_at).not_to be_present
        expect(workflow.failed_at).to be_present
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end

    context "when all steps are completed" do
      before { workflow.workflow_steps.each { |s| s.update!(state: "completed") } }

      it "changes the workflow state to completed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("pending").to("completed")

        workflow.reload

        expect(workflow.completed_at).to be_present
        expect(workflow.failed_at).not_to be_present
      end

      it "does not enqueue any jobs" do
        expect { job.perform(workflow) }
          .not_to have_enqueued_job
      end
    end

    context "when steps are still in progress" do
      before do
        workflow.workflow_steps.find_by(name: "one").update!(state: "completed")
        workflow.workflow_steps.find_by(name: "two").update!(state: "processing")
      end

      it "changes the workflow state to processing" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("pending").to("processing")

        workflow.reload

        expect(workflow.completed_at).not_to be_present
        expect(workflow.failed_at).not_to be_present
      end

      it "enqueues workflow step jobs" do
        expect { job.perform(workflow) }
          .to have_enqueued_job(Workflows::WorkflowStepJob)
          .with(workflow, workflow.workflow_steps.find_by(name: "three"))
      end
    end
  end
end
