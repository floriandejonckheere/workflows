# frozen_string_literal: true

##
# Dependency graph:
#
# one
# └── three ──┐
#             four
# two ────────┘
#
class WorkflowThree < Workflows::Workflow
  workflow do
    step :one
    step :two
    step :three, depends_on: [:one]
    step :four, depends_on: [:two, :three]
  end
end
