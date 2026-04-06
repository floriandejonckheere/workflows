# frozen_string_literal: true

##
# Simple, linear workflow (no namespace)
#
# validate_format
# └── extract_metadata
#     └── generate_thumbnails
#         └── upload_to_cdn
#             └── publish_video
#
class VideoProcessingWorkflow < Workflows::Workflow
  workflow do
    step :validate_format

    step :extract_metadata,
         depends_on: [:validate_format]

    step :generate_thumbnails,
         depends_on: [:extract_metadata]

    step :upload_to_cdn,
         depends_on: [:generate_thumbnails]

    step :publish_video,
         depends_on: [:upload_to_cdn]
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
