# frozen_string_literal: true

RSpec.describe Workflows::Step do
  subject(:step) { described_class.new }

  it { is_expected.to belong_to :workflow }
end
