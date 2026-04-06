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

  describe "state transitions" do
    context "when the workflow step is pending" do
      before { workflow_step.update!(state: "pending") }

      it "changes the workflow step status to completed on success" do
        expect { job.perform(workflow, workflow_step) }
          .to change { workflow_step.reload.state }
          .from("pending").to("completed")

        expect(workflow_step.completed_at).to be_present
        expect(workflow_step.failed_at).to be_nil
      end

      it "changes the workflow step status to failed on failure" do
        allow(workflow_step)
          .to receive(:call)
          .and_raise ArgumentError, "This is an error message"

        expect { expect { job.perform(workflow, workflow_step) }.to raise_error ArgumentError }
          .to change { workflow_step.reload.state }
          .from("pending").to("failed")

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

      context "when a condition is specified" do
        describe "condition passed as symbol" do
          let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

          it "changes the workflow step status to skipped if condition returns false" do
            workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

            ClimateControl.modify SECOND: "0" do
              expect { job.perform(workflow, workflow_step) }
                .to change { workflow_step.reload.state }
                .from("pending").to("skipped")

              expect(workflow_step.completed_at).to be_present
              expect(workflow_step.failed_at).to be_nil
            end
          end

          it "does not change the workflow step status to skipped if condition returns true" do
            workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

            ClimateControl.modify SECOND: "1" do
              expect { job.perform(workflow, workflow_step) }
                .to change { workflow_step.reload.state }
                .from("pending").to("completed")
            end
          end
        end

        describe "condition passed as proc" do
          let(:workflow_step) { workflow.workflow_steps.find_by(name: "fourth") }

          it "changes the workflow step status to skipped if condition returns false" do
            workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

            expect { job.perform(workflow, workflow_step, fourth: false) }
              .to change { workflow_step.reload.state }
              .from("pending").to("skipped")

            expect(workflow_step.completed_at).to be_present
            expect(workflow_step.failed_at).to be_nil
          end

          it "does not change the workflow step status to skipped if condition returns true" do
            workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

            expect { job.perform(workflow, workflow_step, fourth: true) }
              .to change { workflow_step.reload.state }
              .from("pending").to("completed")
          end
        end
      end
    end

    context "when the workflow step is processing" do
      before { workflow_step.update!(state: "processing") }

      it "changes the workflow step status to completed on success" do
        expect { job.perform(workflow, workflow_step) }
          .to change { workflow_step.reload.state }
          .from("processing").to("completed")

        expect(workflow_step.completed_at).to be_present
        expect(workflow_step.failed_at).to be_nil
      end

      it "changes the workflow step status to failed on failure" do
        allow(workflow_step)
          .to receive(:call)
          .and_raise ArgumentError, "This is an error message"

        expect { expect { job.perform(workflow, workflow_step) }.to raise_error ArgumentError }
          .to change { workflow_step.reload.state }
          .from("processing").to("failed")

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

      context "when a condition is specified" do
        describe "condition passed as symbol" do
          let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

          it "changes the workflow step status to skipped if condition returns false" do
            workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

            ClimateControl.modify SECOND: "0" do
              expect { job.perform(workflow, workflow_step) }
                .to change { workflow_step.reload.state }
                .from("processing").to("skipped")

              expect(workflow_step.completed_at).to be_present
              expect(workflow_step.failed_at).to be_nil
            end
          end

          it "does not change the workflow step status to skipped if condition returns true" do
            workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

            ClimateControl.modify SECOND: "1" do
              expect { job.perform(workflow, workflow_step) }
                .to change { workflow_step.reload.state }
                .from("processing").to("completed")
            end
          end
        end

        describe "condition passed as proc" do
          let(:workflow_step) { workflow.workflow_steps.find_by(name: "fourth") }

          it "changes the workflow step status to skipped if condition returns false" do
            workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

            expect { job.perform(workflow, workflow_step, fourth: false) }
              .to change { workflow_step.reload.state }
              .from("processing").to("skipped")

            expect(workflow_step.completed_at).to be_present
            expect(workflow_step.failed_at).to be_nil
          end

          it "does not change the workflow step status to skipped if condition returns true" do
            workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

            expect { job.perform(workflow, workflow_step, fourth: true) }
              .to change { workflow_step.reload.state }
              .from("processing").to("completed")
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

      it "passes arguments to the workflow job" do
        expect { job.perform(workflow, workflow_step, "argument_one", argument: "two") }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow, "argument_one", argument: "two")
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

      it "passes arguments to the workflow job" do
        expect { job.perform(workflow, workflow_step, "argument_one", argument: "two") }
          .to have_enqueued_job(Workflows::WorkflowJob)
          .exactly(:once)
          .with(workflow, "argument_one", argument: "two")
      end
    end
  end

  describe "step executing" do
    it "executes the step" do
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

    context "when the workflow step is completed" do
      it "does not execute the step" do
        workflow_step.update!(state: "completed")

        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .not_to have_received(:call)
      end
    end

    context "when the workflow step is failed" do
      it "does not execute the step" do
        workflow_step.update!(state: "failed")

        allow(workflow_step)
          .to receive(:call)
          .and_call_original

        job.perform(workflow, workflow_step)

        expect(workflow_step)
          .not_to have_received(:call)
      end
    end

    context "when not all of the dependencies are complete" do
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

    context "when some dependencies are skipped" do
      let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

      it "executes the step" do
        workflow.workflow_steps.find_by(name: "first").update!(state: "skipped")

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
      describe "condition passed as symbol" do
        let(:workflow_step) { workflow.workflow_steps.find_by(name: "second") }

        it "does not execute the step if condition returns false" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

          ClimateControl.modify SECOND: "0" do
            allow(workflow_step)
              .to receive(:call)
              .and_call_original

            job.perform(workflow, workflow_step)

            expect(workflow_step)
              .not_to have_received(:call)
          end
        end

        it "executes the step if condition returns true" do
          workflow.workflow_steps.find_by(name: "first").update!(state: "completed")

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

      describe "condition passed as proc" do
        let(:workflow_step) { workflow.workflow_steps.find_by(name: "fourth") }

        it "does not execute the step if condition returns false" do
          workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

          allow(workflow_step)
            .to receive(:call)
            .and_call_original

          job.perform(workflow, workflow_step, fourth: false)

          expect(workflow_step)
            .not_to have_received(:call)
        end

        it "executes the step if condition returns true" do
          workflow.workflow_steps.find_by(name: "third").update!(state: "completed")

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
end
