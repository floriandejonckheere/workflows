# frozen_string_literal: true

##
# Simple, linear workflow
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
