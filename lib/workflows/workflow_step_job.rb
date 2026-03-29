# frozen_string_literal: true

module Workflows
  class WorkflowStepJob < Workflows.configuration.parent_job_class.constantize
    limits_concurrency to: 1,
                       key: ->(step) { step },
                       duration: 1.minute,
                       on_conflict: :block

    # TODO: allow passing arguments
    def perform(workflow, workflow_step)
      # Nothing to do if this workflow step has already been finalized
      return if workflow_step.completed? || workflow_step.failed?

      # Check if workflow step can be executed

      # Mark as processing
      workflow_step
        .update!(state: "processing", completed_at: nil, failed_at: nil, error_class: nil, error_message: nil)

      # Execute step logic
      type = workflow_step
        .abstract_workflow_step
        .type

      "#{type.camelize}Step"
        .constantize
        .call
    rescue StandardError => e
      workflow_step
        .update!(state: "failed", completed_at: nil, failed_at: Time.zone.now, error_class: e.class.name, error_message: e.message)

      raise
    ensure
      # Call workflow job again on completion/failure to update workflow state and schedule other jobs
      WorkflowJob
        .perform_later(workflow)
    end
  end
end
