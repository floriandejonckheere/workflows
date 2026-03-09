# frozen_string_literal: true

RSpec.describe Workflows::Version do
  it "has a version number" do
    expect(Workflows::VERSION).not_to be_nil
  end
end
