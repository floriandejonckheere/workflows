# frozen_string_literal: true

module Workflows
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Workflows.loader.eager_load
    end

    generators do
      require "generators/workflows/install_generator"
    end
  end
end
