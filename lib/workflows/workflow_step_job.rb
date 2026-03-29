# frozen_string_literal: true

module Workflows
  class WorkflowStepJob < Workflows.configuration.parent_job_class.constantize
    limits_concurrency to: 1,
                       key: ->(step) { step },
                       duration: 1.minute,
                       on_conflict: :block

    def perform(workflow, workflow_step, *, **)
      # Nothing to do if this workflow step has already been finalized
      return if workflow_step.completed? || workflow_step.failed?

      # Find all completed step names
      completed_step_names = workflow
        .workflow_steps
        .completed
        .map(&:name)

      # Check if workflow step can be executed
      return unless workflow_step.abstract_workflow_step.depends_on.all? { |dep| dep.to_s.in? completed_step_names }

      # Mark as processing
      workflow_step
        .update!(state: "processing", completed_at: nil, failed_at: nil, error_class: nil, error_message: nil)

      # Execute step logic
      workflow_step
        .call(*, **)

      # Mark as complete
      workflow_step
        .update!(state: "completed", completed_at: Time.zone.now)
    rescue StandardError => e
      workflow_step
        .update!(state: "failed", completed_at: nil, failed_at: Time.zone.now, error_class: e.class.name, error_message: e.message)

      raise
    ensure
      # Call workflow job again on completion/failure to update workflow state and schedule other jobs
      # TODO: allow specifying job options (delay, ...)
      WorkflowJob
        .perform_later(workflow, *, **)
    end
  end
end
