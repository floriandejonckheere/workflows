# frozen_string_literal: true

RSpec.describe Workflows::Workflow do
  subject(:workflow) { described_class.new }

  it { is_expected.to have_many :steps }
end
