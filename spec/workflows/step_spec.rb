# frozen_string_literal: true

RSpec.describe Workflows::Step do
  subject(:step) { create(:step) }

  describe "associations" do
    it { is_expected.to belong_to(:workflow) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:workflow_id) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
  end
end
