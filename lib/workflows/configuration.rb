# frozen_string_literal: true

module Workflows
  class Configuration
    def parent_model_class
      @parent_model_class ||= "ActiveRecord::Base"
    end

    def parent_model_class=(value)
      @parent_model_class = value.to_s
    end
  end
end
