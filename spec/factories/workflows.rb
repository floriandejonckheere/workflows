# frozen_string_literal: true

FactoryBot.define do
  factory :workflow, class: "Workflows::Workflow" do
    name { "my_workflow" }
    class_name { "MyWorkflow" }
    state { "pending" }

    trait :with_steps do
      transient do
        workflow_steps { [] }
      end

      after(:build) do |workflow, evaluator|
        evaluator.workflow_steps.each do |step|
          attributes = step.is_a?(Hash) ? step.dup : { type: }
          traits = Array(attributes.delete(:traits))

          workflow.steps << build(:step, *traits, workflow:, **attributes)
        end
      end

      after(:create) do |workflow|
        workflow.steps.select(&:new_record?).each(&:save!)
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
