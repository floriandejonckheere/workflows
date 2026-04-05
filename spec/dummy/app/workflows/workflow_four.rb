# frozen_string_literal: true

##
# Dependency graph:
#
# one
# ├── three
# │   └── four
# └── two
#
class WorkflowFour < Workflows::Workflow
  workflow do
    step :one
    step :two, depends_on: [:one]
    step :three, depends_on: [:one]
    step :four, depends_on: [:three]
  end
end
