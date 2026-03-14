# frozen_string_literal: true

RSpec.describe Workflows::Workflow do
  subject(:workflow) { described_class.new }

  describe "associations" do
    it { is_expected.to have_many(:steps).dependent(:destroy).inverse_of(:workflow) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
  end
end
