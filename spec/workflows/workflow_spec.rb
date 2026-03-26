# frozen_string_literal: true

RSpec.describe Workflows::Workflow do
  subject(:workflow) { create(:workflow) }

  describe "associations" do
    it { is_expected.to have_many(:workflow_steps).dependent(:destroy).inverse_of(:workflow) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:type) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
  end

  describe "#all_workflow_steps_completed?" do
    context "when all steps are completed" do
      before { create_list(:workflow_step, 2, :completed, workflow:) }

      it { expect(workflow).to be_all_workflow_steps_completed }
    end

    context "when some workflow steps are not completed" do
      before do
        create(:workflow_step, :completed, workflow:)
        create(:workflow_step, workflow:)
      end

      it { expect(workflow).not_to be_all_workflow_steps_completed }
    end

    context "when there are no workflow steps" do
      it { expect(workflow).not_to be_all_workflow_steps_completed }
    end
  end

  describe "#any_workflow_step_failed?" do
    context "when a step has failed" do
      before { create(:workflow_step, :failed, workflow:) }

      it { expect(workflow).to be_any_workflow_step_failed }
    end

    context "when no workflow steps have failed" do
      before { create(:workflow_step, :completed, workflow:) }

      it { expect(workflow).not_to be_any_workflow_step_failed }
    end
  end
end
