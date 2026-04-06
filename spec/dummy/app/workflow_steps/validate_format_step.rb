# frozen_string_literal: true

class ValidateFormatStep < Workflows::WorkflowStep
end

# == Schema Information
#
# Table name: workflow_steps
# Database name: primary
#
#  id            :integer          not null, primary key
#  completed_at  :datetime
#  error_class   :string
#  error_message :text
#  failed_at     :datetime
#  name          :string           not null
#  state         :string           default("pending"), not null
#  type          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  workflow_id   :integer          not null
#
# Indexes
#
#  index_workflow_steps_on_workflow_id           (workflow_id)
#  index_workflow_steps_on_workflow_id_and_name  (workflow_id,name) UNIQUE
#
# Foreign Keys
#
#  workflow_id  (workflow_id => workflows.id) ON DELETE => cascade
#
