# frozen_string_literal: true

module Workflows
  module DSL
    extend ActiveSupport::Concern

    included do
      class_attribute :_steps,
                      default: []
    end

    class_methods do
      def workflow
        yield self
      end

      def step(name, depends_on: [])
        _steps << Step.new(name, depends_on:)
      end
    end

    class Step
      attr_reader :name,
                  :depends_on

      def initialize(name, depends_on: [])
        @name = name
        @depends_on = depends_on
      end
    end
  end
end
