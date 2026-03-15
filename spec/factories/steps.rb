# frozen_string_literal: true

FactoryBot.define do
  factory :step, class: "Workflows::Step" do
    workflow
    sequence(:name) { |i| "step_#{i}" }
    type { "Workflows::Step" }
    state { "pending" }

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
