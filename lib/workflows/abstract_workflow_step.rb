# frozen_string_literal: true

module Workflows
  class AbstractWorkflowStep
    attr_reader :name,
                :type,
                :depends_on,
                :condition,
                :namespace

    def initialize(name, depends_on: [], condition: nil, type: nil, namespace: nil)
      @name = name
      @depends_on = depends_on
      @condition = condition
      @namespace = namespace

      @type = [namespace.to_s.camelize, type || "#{name.to_s.camelize}Step"]
        .compact
        .join("::")
        .constantize
    end

    def skip?(workflow, *, **)
      return false unless condition

      # Condition is a block/proc
      return condition.call(*, **) if condition.respond_to?(:call)

      # Condition is a symbol
      workflow.public_send(condition, *, **)
    end

    def inspect
      "#<Workflows::AbstractWorkflowStep name=#{name} type=#{type}>"
    end
  end
end
