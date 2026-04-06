# frozen_string_literal: true

##
# Complex workflow with diamond dependency pattern
#
# load_video
# ├── extract_audio
#     └── encode_audio
#         └── merge_video_and_audio
# └── extract_video
#     └── encode_video
#         └── merge_video_and_audio
#
class VideoEncodingWorkflow < Workflows::Workflow
  workflow :video_encoding do
    step :load_video

    step :extract_audio,
         depends_on: [:load_video]

    step :encode_audio,
         depends_on: [:extract_audio]

    step :extract_video,
         depends_on: [:load_video]

    step :encode_video,
         depends_on: [:extract_video]

    step :merge_video_and_audio,
         depends_on: [:encode_audio, :encode_video]
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
