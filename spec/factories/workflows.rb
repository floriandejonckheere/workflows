# frozen_string_literal: true

FactoryBot.define do
  factory :workflow, class: "Workflows::Workflow" do
    type { "Workflows::Workflow" }
    state { "pending" }

    transient do
      workflow_step_statuses { {} }
    end

    initialize_with do
      klass = type.constantize
      klass.new(attributes.except(:workflow_step_statuses))
    end

    after(:create) do |workflow, evaluator|
      evaluator.workflow_step_statuses.each do |name, state|
        workflow.workflow_steps.find_by!(name: name.to_s).update!(state: state.to_s)
      end
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

    trait :video_processing do
      type { VideoProcessingWorkflow.name }
    end

    trait :checkout do
      type { CheckoutWorkflow.name }
    end

    trait :thumbnail_generation do
      type { ThumbnailGenerationWorkflow.name }
    end

    trait :email_campaign_dispatch do
      type { EmailCampaignDispatchWorkflow.name }
    end

    trait :data_ingestion_pipeline do
      type { DataIngestionPipelineWorkflow.name }
    end

    trait :document_processing do
      type { DocumentProcessingWorkflow.name }
    end

    trait :order_fulfillment do
      type { OrderFulfillmentWorkflow.name }
    end

    trait :video_encoding do
      type { VideoEncodingWorkflow.name }
    end
  end
end
