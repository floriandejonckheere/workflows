# frozen_string_literal: true

RSpec.describe Workflows::DSL::Workflow do
  subject(:workflow) { create(:workflow, :video_processing) }

  describe "callbacks" do
    it "creates workflow steps after creation" do
      expect { workflow.save! }
        .to change(Workflows::WorkflowStep, :count)
        .by(5)

      validate_format, extract_metadata, generate_thumbnails, upload_to_cdn, publish_video = workflow.workflow_steps

      expect(validate_format).to be_a ValidateFormatStep
      expect(validate_format.name).to eq "validate_format"

      expect(extract_metadata).to be_a ExtractMetadataStep
      expect(extract_metadata.name).to eq "extract_metadata"

      expect(generate_thumbnails).to be_a GenerateThumbnailsStep
      expect(generate_thumbnails.name).to eq "generate_thumbnails"

      expect(upload_to_cdn).to be_a UploadToCdnStep
      expect(upload_to_cdn.name).to eq "upload_to_cdn"

      expect(publish_video).to be_a PublishVideoStep
      expect(publish_video.name).to eq "publish_video"
    end
  end

  describe "#perform_later" do
    it "enqueues a workflow job" do
      expect { workflow.perform_later }
        .to have_enqueued_job(Workflows::WorkflowJob)
        .exactly(:once)
        .with(workflow)
    end

    it "passes arguments to the workflow job" do
      expect { workflow.perform_later("argument_one", argument: "two") }
        .to have_enqueued_job(Workflows::WorkflowJob)
        .exactly(:once)
        .with(workflow, "argument_one", argument: "two")
    end
  end

  describe ".workflow" do
    it "defines an abstract workflow" do
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow { nil }

      expect(klass.abstract_workflow).to be_a Workflows::AbstractWorkflow
    end

    it "defines an abstract workflow with a namespace" do
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow(:namespace) { nil }

      expect(klass.abstract_workflow.namespace).to eq :namespace
    end

    it "overrides an existing workflow" do
      klass = Class.new(Workflows::Workflow) do
        include Workflows::DSL
      end

      klass.workflow { nil }

      abstract_workflow = klass.abstract_workflow

      klass.workflow { nil }

      expect(klass.abstract_workflow).not_to eq abstract_workflow
    end
  end

  describe ".step" do
    it "defines an abstract workflow step" do
      abstract_workflow = workflow.abstract_workflow

      validate_format = abstract_workflow.abstract_workflow_steps[:validate_format]
      expect(validate_format).to be_a Workflows::AbstractWorkflowStep
      expect(validate_format.name).to eq :validate_format
      expect(validate_format.depends_on).to be_empty
      expect(validate_format.type).to eq ValidateFormatStep

      extract_metadata = abstract_workflow.abstract_workflow_steps[:extract_metadata]
      expect(extract_metadata).to be_a Workflows::AbstractWorkflowStep
      expect(extract_metadata.name).to eq :extract_metadata
      expect(extract_metadata.depends_on).to contain_exactly(:validate_format)
      expect(extract_metadata.type).to eq ExtractMetadataStep

      generate_thumbnails = abstract_workflow.abstract_workflow_steps[:generate_thumbnails]
      expect(generate_thumbnails).to be_a Workflows::AbstractWorkflowStep
      expect(generate_thumbnails.name).to eq :generate_thumbnails
      expect(generate_thumbnails.depends_on).to contain_exactly(:extract_metadata)
      expect(generate_thumbnails.type).to eq GenerateThumbnailsStep

      upload_to_cdn = abstract_workflow.abstract_workflow_steps[:upload_to_cdn]
      expect(upload_to_cdn).to be_a Workflows::AbstractWorkflowStep
      expect(upload_to_cdn.name).to eq :upload_to_cdn
      expect(upload_to_cdn.depends_on).to contain_exactly(:generate_thumbnails)
      expect(upload_to_cdn.type).to eq UploadToCdnStep

      publish_video = abstract_workflow.abstract_workflow_steps[:publish_video]
      expect(publish_video).to be_a Workflows::AbstractWorkflowStep
      expect(publish_video.name).to eq :publish_video
      expect(publish_video.depends_on).to contain_exactly(:upload_to_cdn)
      expect(publish_video.type).to eq PublishVideoStep
    end

    it "raises when a step is already defined" do
      expect { VideoProcessingWorkflow.step :validate_format }
        .to raise_error ArgumentError
    end
  end
end
