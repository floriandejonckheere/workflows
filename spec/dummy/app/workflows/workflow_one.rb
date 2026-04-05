# frozen_string_literal: true

##
# Dependency graph:
#
# one
# └── two
#     └── three
#         └── four
#             └── five
#
class WorkflowOne < Workflows::Workflow
  workflow do
    step :one

    step :two,
         depends_on: [:one]

    step :three,
         depends_on: [:two]

    step :four,
         depends_on: [:three]

    step :five,
         type: "OneStep",
         depends_on: [:four]
  end
end
