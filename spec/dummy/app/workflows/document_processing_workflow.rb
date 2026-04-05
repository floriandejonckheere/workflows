# frozen_string_literal: true

##
# Complex workflow with linear sequential steps
#
# upload_document
# └── scan_for_pii
#     └── extract_text
#         └── classify_document_type
#             └── route_to_reviewer
#                 └── generate_audit_log
#                     └── archive
#
class DocumentProcessingWorkflow < Workflows::Workflow
  workflow :document_processing do
    step :upload_document

    step :scan_for_pii,
         depends_on: [:upload_document]

    step :extract_text,
         depends_on: [:scan_for_pii]

    step :classify_document_type,
         depends_on: [:extract_text]

    step :route_to_reviewer,
         depends_on: [:classify_document_type]

    step :generate_audit_log,
         depends_on: [:route_to_reviewer]

    step :archive,
         depends_on: [:generate_audit_log]
  end
end
