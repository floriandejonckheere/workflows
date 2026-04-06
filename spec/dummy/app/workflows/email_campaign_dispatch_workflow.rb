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
