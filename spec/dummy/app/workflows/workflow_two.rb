# frozen_string_literal: true

##
# Dependency graph:
#
# nested/one
#
class WorkflowTwo < Workflows::Workflow
  workflow :nested do
    step :one
  end
end
