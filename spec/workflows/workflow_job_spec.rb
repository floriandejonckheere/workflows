# frozen_string_literal: true

RSpec.describe Workflows::WorkflowJob do
  subject(:job) { described_class.new }

  let(:workflow) { workflow_three_class.create! }

  include_context "workflows"

  describe "#perform" do
    context "when the workflow is pending" do
      let(:workflow) { create(:workflow, :pending, type: workflow_three_class.name) }

      it "changes the workflow status to processing" do
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
      let(:workflow) do
        create(
          :workflow,
          :processing,
          :with_workflow_steps,
          transient_workflow_steps: [
            "four",
            { name: "two", traits: [:failed] },
            "three",
            "one",
          ],
        )
      end

      it "changes the workflow status to failed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("processing").to("failed")

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
      let(:workflow) do
        create(
          :workflow,
          :processing,
          :with_workflow_steps,
          transient_workflow_steps: [
            { name: "four", traits: [:completed] },
            { name: "two", traits: [:completed] },
            { name: "three", traits: [:completed] },
            { name: "one", traits: [:completed] },
          ],
        )
      end

      it "changes the workflow state to completed" do
        expect { job.perform(workflow) }
          .to change { workflow.reload.state }
          .from("processing").to("completed")

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
      let(:workflow) do
        create(:workflow, :processing, type: workflow_three_class.name).tap do |w|
          w.workflow_steps.find_by!(name: :one).update!(state: "completed", completed_at: Time.current)
          w.workflow_steps.find_by!(name: :two).update!(state: "processing")
        end
      end

      it "does not change the workflow state" do
        expect { job.perform(workflow) }
          .not_to(change { workflow.reload.state })

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
