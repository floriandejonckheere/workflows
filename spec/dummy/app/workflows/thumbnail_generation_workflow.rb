# frozen_string_literal: true

##
# Simple, linear workflow
#
# validate_image
# └── extract_metadata
#     └── generate_thumbnail
#
class ThumbnailGenerationWorkflow < Workflows::Workflow
  workflow :thumbnail_generation do
    step :validate_image

    step :extract_metadata,
         depends_on: [:validate_image]

    step :generate_thumbnail,
         depends_on: [:extract_metadata]
  end
end
