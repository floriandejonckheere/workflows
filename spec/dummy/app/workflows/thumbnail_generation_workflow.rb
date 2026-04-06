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
