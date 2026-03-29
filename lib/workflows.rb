# frozen_string_literal: true

require "rails"

require "zeitwerk"

module Workflows
  class << self
    # Code loader instance
    attr_reader :loader

    def root
      @root ||= Pathname.new(File.expand_path(File.join("..", ".."), __FILE__))
    end

    def setup
      @loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)

      # Register inflections
      require root.join("config/inflections.rb")

      # Ignore generators directory — Rails handles loading these, not Zeitwerk
      loader.ignore(root.join("lib/generators"))

      loader.setup
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end

Workflows.setup
