# frozen_string_literal: true

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
