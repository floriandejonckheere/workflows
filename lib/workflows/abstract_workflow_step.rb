# frozen_string_literal: true

module Workflows
  class AbstractWorkflowStep
    attr_reader :name,
                :type,
                :depends_on

    def initialize(name, depends_on: [], type: nil)
      @name = name
      @depends_on = depends_on
      @type = (type || "#{name.to_s.camelize}Step").constantize
    end
  end
end
