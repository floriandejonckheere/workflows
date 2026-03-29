# frozen_string_literal: true

FactoryBot.define do
  factory :workflow, class: "Workflows::Workflow" do
    type { "Workflows::Workflow" }
    state { "pending" }

    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    trait :with_workflow_steps do
      transient do
        transient_workflow_steps { [] }
      end

      after(:build) do |workflow, evaluator|
        evaluator.transient_workflow_steps.each do |step|
          attributes = step.is_a?(Hash) ? step.dup : {}
          traits = Array(attributes.delete(:traits))

          workflow.workflow_steps << build(:workflow_step, *traits, workflow:, **attributes)
        end
      end

      after(:create) do |workflow|
        workflow.workflow_steps.select(&:new_record?).each(&:save!)
      end
    end

    trait :processing do
      state { "processing" }
    end

    trait :completed do
      state { "completed" }
      completed_at { Time.zone.now }
    end

    trait :failed do
      state { "failed" }
      failed_at { Time.zone.now }
    end
  end
end
