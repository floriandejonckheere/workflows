# frozen_string_literal: true

module Workflows
  class AbstractStep
    attr_reader :name,
                :depends_on,
                :class_name

    def initialize(name, depends_on: [], class_name: nil)
      @name = name
      @depends_on = depends_on
      @class_name = (class_name || "#{name.to_s.camelize}Step").constantize
    end
  end
end
