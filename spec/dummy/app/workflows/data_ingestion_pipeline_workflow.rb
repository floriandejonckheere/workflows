# frozen_string_literal: true

##
# Complex workflow with parallel branches and linear pipeline
#
# fetch_data
# ├── validate_schema
# │   └── deduplicate
# └── prepare_destination
#     └── deduplicate
#         └── transform
#             └── store_in_warehouse
#                 └── index_for_search
#
class DataIngestionPipelineWorkflow < Workflows::Workflow
  workflow :data_ingestion_pipeline do
    step :fetch_data

    step :validate_schema,
         depends_on: [:fetch_data]

    step :prepare_destination,
         depends_on: [:fetch_data]

    step :deduplicate,
         depends_on: [:validate_schema, :prepare_destination]

    step :transform,
         depends_on: [:deduplicate]

    step :store_in_warehouse,
         depends_on: [:transform]

    step :index_for_search,
         depends_on: [:store_in_warehouse]
  end
end

# == Schema Information
#
# Table name: workflows
# Database name: primary
#
#  id           :integer          not null, primary key
#  completed_at :datetime
#  failed_at    :datetime
#  state        :string           default("pending"), not null
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
