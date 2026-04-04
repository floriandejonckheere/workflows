# frozen_string_literal: true

RSpec.describe Workflows::WorkflowJob do
  subject(:job) { described_class.new }

  let(:workflow) { create(:workflow, type: workflow_three_class.name) }

  include_context "workflows"

  describe "#perform" do
    ["pending", "processing"].each do |state|
      context "when the workflow is #{state}" do
        before { workflow.update!(state:) }

        if state == "pending"
          it "changes the workflow state to processing" do
            expect { job.perform(workflow) }
              .to change { workflow.reload.state }
              .from("pending").to("processing")
          end
        else
          it "does not change the workflow state" do
            expect { job.perform(workflow) }
              .not_to(change { workflow.reload.state })
          end
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
    end

    context "when the workflow is completed" do
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

    context "when the workflow is failed" do
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
  end
end
