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

  let(:workflow) { create(:workflow, :email_campaign_dispatch, type: workflow_class.name) }

  before do
    stub_const("Step", step_class)
    stub_const("Workflow", workflow_class)
  end

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
            .with(workflow, workflow.workflow_steps.find_by(name: "first"))
        end

        it "passes arguments to workflow step jobs" do
          expect { job.perform(workflow, "argument_one", argument: "two") }
            .to have_enqueued_job(Workflows::WorkflowStepJob)
            .exactly(:once)
            .with(workflow, workflow.workflow_steps.find_by(name: "first"), "argument_one", argument: "two")
        end

        context "when any workflow step is failed" do
          it "changes the workflow state to failed" do
            workflow.workflow_steps.find_by(name: "first").update!(state: "completed")
            workflow.workflow_steps.find_by(name: "second").update!(state: "failed")

            expect { job.perform(workflow) }
              .to change { workflow.reload.state }
              .from(state).to("failed")

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
              .from(state).to("completed")

            expect(workflow.completed_at).to be_present
            expect(workflow.failed_at).to be_nil
          end
        end
      end
    end

    context "when the workflow is completed" do
      let(:workflow) { create(:workflow, :email_campaign_dispatch, :completed) }

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
      let(:workflow) { create(:workflow, :email_campaign_dispatch, :failed) }

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
