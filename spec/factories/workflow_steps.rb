# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_step, class: "Workflows::WorkflowStep" do
    workflow

    type { "Workflows::WorkflowStep" }
    sequence(:name) { |i| "my_workflow_step_#{i}" }
    state { "pending" }

    trait :pending do
      state { "pending" }
    end

    trait :enqueued do
      state { "enqueued" }
    end

    trait :processing do
      state { "processing" }
    end

    trait :completed do
      state { "completed" }
      completed_at { Time.current }
    end

    trait :failed do
      state { "failed" }
      failed_at { Time.current }
      error_class { "StandardError" }
      error_message { "Something went wrong" }
    end
  end
end
