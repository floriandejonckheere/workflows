# frozen_string_literal: true

module Workflows
  class AbstractStep
    attr_reader :name,
                :depends_on

    def initialize(name, depends_on: [])
      @name = name
      @depends_on = depends_on
    end
  end
end
