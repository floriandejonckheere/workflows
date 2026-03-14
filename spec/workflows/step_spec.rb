# frozen_string_literal: true

RSpec.describe Workflows::Step do
  subject(:step) { described_class.new }

  describe "associations" do
    it { is_expected.to belong_to :workflow }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
  end
end
