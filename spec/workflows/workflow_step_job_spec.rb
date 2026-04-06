# frozen_string_literal: true

RSpec.describe Workflows::WorkflowStepJob do
  subject(:job) { described_class.new }

  let(:workflow) { EmailCampaignDispatchWorkflow.create! }
  let(:workflow_step) { workflow.workflow_steps.find_by(name: "load_recipients") }

  describe "#perform" do
    ["pending", "processing"].each do |state|
      context "when the workflow step is #{state}" do
        before { workflow_step.update!(state:) }

        it "changes the workflow step status to completed on success" do
          expect { job.perform(workflow, workflow_step) }
            .to change { workflow_step.reload.state }
            .from(state).to("completed")

          expect(workflow_step.completed_at).to be_present
          expect(workflow_step.failed_at).to be_nil
        end

        it "changes the workflow step status to failed on failure" do
          allow(workflow_step)
            .to receive(:call)
            .and_raise ArgumentError, "This is an error message"

          expect { expect { job.perform(workflow, workflow_step) }.to raise_error ArgumentError }
            .to change { workflow_step.reload.state }
            .from(state).to("failed")

          expect(workflow_step.completed_at).to be_nil
          expect(workflow_step.failed_at).to be_present
          expect(workflow_step.error_class).to eq "ArgumentError"
          expect(workflow_step.error_message).to eq "This is an error message"
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

        it "performs the step" do
          allow(workflow_step)
            .to receive(:call)
            .and_call_original

          job.perform(workflow, workflow_step)

          expect(workflow_step)
            .to have_received(:call)
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

        context "when not all of the dependencies are complete" do
          let(:workflow_step) { workflow.workflow_steps.find_by(name: "send_emails") }

          it "does not change the workflow step state" do
            expect { job.perform(workflow, workflow_step) }
              .not_to(change { workflow_step.reload.state })
          end

          it "enqueues a workflow job" do
            expect { job.perform(workflow, workflow_step) }
              .to have_enqueued_job(Workflows::WorkflowJob)
              .exactly(:once)
              .with(workflow)
          end

          it "does not perform the step" do
            allow(workflow_step)
              .to receive(:call)
              .and_call_original

            job.perform(workflow, workflow_step)

            expect(workflow_step)
              .not_to have_received(:call)
          end
        end
      end
    end

    context "when the workflow step is completed" do
      before { workflow_step.update!(state: "completed") }

      it "does not change the workflow step state" do
        expect { job.perform(workflow, workflow_step) }
          .not_to(change { workflow_step.reload.state })
      end

      it "enqueues a workflow job" do
        expect { job.perform(workflow, workflow_step) }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow)
      end

      it "does not perform the step" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .not_to have_received(:call)
      end
    end

    context "when the workflow step is failed" do
      before { workflow_step.update!(state: "failed") }

      it "does not change the workflow step state" do
        expect { job.perform(workflow, workflow_step) }
          .not_to(change { workflow_step.reload.state })
      end

      it "enqueues a workflow job" do
        expect { job.perform(workflow, workflow_step) }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow)
      end

      it "does not perform the step" do
        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .not_to have_received(:call)
      end
    end
  end
end
