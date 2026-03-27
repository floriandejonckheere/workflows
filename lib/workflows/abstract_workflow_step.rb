# frozen_string_literal: true

module Workflows
  class AbstractWorkflowStep
    attr_reader :name,
                :type,
                :depends_on,
                :namespace

    def initialize(name, depends_on: [], type: nil, namespace: nil)
      @name = name
      @depends_on = depends_on
      @namespace = namespace

      @type = [namespace.to_s.camelize, type || "#{name.to_s.camelize}Step"]
        .compact
        .join("::")
        .constantize
    end

    def inspect
      "#<Workflows::AbstractWorkflowStep name=#{name} type=#{type}>"
    end
  end
end
