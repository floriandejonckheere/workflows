# frozen_string_literal: true

##
# Simple workflow with fan-in convergence
#
# load_recipients
# ├── validate_email_list
# │   └── send_emails
# └── prepare_email_content
#     └── send_emails
#
class EmailCampaignDispatchWorkflow < Workflows::Workflow
  workflow :email_campaign_dispatch do
    step :load_recipients

    step :validate_email_list,
         depends_on: [:load_recipients]

    step :prepare_email_content,
         depends_on: [:load_recipients]

    step :send_emails,
         depends_on: [:validate_email_list, :prepare_email_content]
  end
end
