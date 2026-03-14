# frozen_string_literal: true

module Workflows
  class Railtie < ::Rails::Railtie
    generators do
      require "generators/workflows/install_generator"
    end
  end
end
