# frozen_string_literal: true

##
# Complex workflow with diamond dependency pattern
#
# load_video_for_reencoding
# ├── extract_audio
# │   └── merge_reencoded_output
# └── extract_video
#     └── reencode_video
#         └── merge_reencoded_output
#
class VideoReencodingWorkflow < Workflows::Workflow
  workflow :video_reencoding do
    step :load_video_for_reencoding

    step :extract_audio,
         depends_on: [:load_video_for_reencoding]

    step :extract_video,
         depends_on: [:load_video_for_reencoding]

    step :reencode_video,
         depends_on: [:extract_video]

    step :merge_reencoded_output,
         depends_on: [:extract_audio, :reencode_video]
  end
end
