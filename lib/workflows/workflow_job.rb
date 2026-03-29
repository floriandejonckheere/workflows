# frozen_string_literal: true

module Workflows
  class WorkflowJob < Workflows.configuration.parent_job_class.constantize
    limits_concurrency to: 1,
                       key: ->(workflow) { workflow },
                       duration: 1.minute,
                       on_conflict: :block

    # TODO: allow reprocessing a specific set of steps
    # TODO: allow passing arguments
    def perform(workflow)
      # Nothing to do if this workflow has already been finalized
      return if workflow.completed? || workflow.failed?

      # Check if any of the steps have failed
      if workflow.any_workflow_step_failed?
        workflow
          .update!(state: "failed", failed_at: Time.zone.now)

        return
      end

      # Check if all the steps have been completed
      if workflow.all_workflow_steps_completed?
        workflow
          .update!(state: "completed", completed_at: Time.zone.now)

        return
      end

      # Mark as processing
      workflow
        .update!(state: "processing", completed_at: nil, failed_at: nil)

      # Find all completed step names
      completed_step_names = workflow
        .workflow_steps
        .completed
        .map(&:name)

      # Perform eligible steps (all of its dependencies are satisfied)
      workflow
        .workflow_steps
        .pending
        .select { |step| step.abstract_workflow_step.depends_on.all? { |dep| dep.to_s.in? completed_step_names } }
        .select { |step| WorkflowStepJob.perform_later(workflow, step) } # TODO: use overridable job class
    end
  end
end
