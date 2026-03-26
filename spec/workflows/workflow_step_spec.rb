# frozen_string_literal: true

RSpec.describe Workflows::WorkflowStep do
  subject(:workflow_step) { create(:workflow_step) }

  describe "associations" do
    it { is_expected.to belong_to(:workflow) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:workflow_id) }

    it { is_expected.to validate_presence_of(:type) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(pending: "pending", enqueued: "enqueued", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
  end
end
