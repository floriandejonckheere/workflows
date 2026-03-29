# Workflows

![Continuous Integration](https://github.com/floriandejonckheere/workflows/actions/workflows/ci.yml/badge.svg)
![Release](https://img.shields.io/github/v/release/floriandejonckheere/workflows?label=Latest%20release)

Workflow orchestration framework for Ruby on Rails background processing jobs.

## Prerequisites

- Rails 8.1+
- SolidQueue as ActiveJob adapter

## Installation

Add this line to your application's Gemfile:

```ruby
gem "workflows"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install workflows

Run the installation generator:

    $ rails generate workflows:install

This will create the workflows initializer, migrations, and models.

## Usage

Create a workflow using the generator:

    $ rails generate workflows:workflow video_processing

This will create an `app/workflows/video_processing_workflow.rb` file.

Create workflow steps using the generator:

    $ rails generate workflows:workflow_step video_processing/validate_format
    $ rails generate workflows:workflow_step video_processing/extract_metadata
    $ rails generate workflows:workflow_step video_processing/generate_thumbnails
    $ rails generate workflows:workflow_step video_processing/upload_to_cdn
    $ rails generate workflows:workflow_step video_processing/publish_video

This will create `app/workflows/video_processing/validate_format.rb`, etc.

Then, define the workflow steps in the `video_processing_workflow.rb` file, along with their dependencies:

```ruby
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
```

This workflow is a simple, linear workflow where each subsequent step depends on the previous one.
If a step fails to process, the workflow will halt and not execute the workflow steps that depend on the failed step.

Refer to [`spec/dummy/app/workflows`](spec/dummy/app/workflows) for more comprehensive examples of linear and non-linear workflows. 

### Workflows

Define an abstract workflow on your workflow model by calling the `workflow` method.
This method takes (optionally) a namespace and a block.
The namespace is used to resolve step classes.

```ruby
workflow do
  # ...
end
```

### Steps

Define an abstract step inside your abstract workflow by calling the `step` method.

```ruby
workflow do
  step :do_something
end
```

The step class name is automatically inferred from the step name.
To override this, pass the `type` argument.

```ruby
workflow do
    # Resolves to DoSomethingStep
    step :do_something
    
    # Resolves to DoAnythingStep
    step :do_something_else,
         type: "DoAnything"
end
```

If a namespace is passed to the `workflow`, it is prepended before the step name.

```ruby
workflow :my_namespace do
  # Resolves to MyNamespace::DoSomethingStep
  step :do_something
  
  # Resolves to MyNamespace::DoAnythingStep
  step :do_something_else,
       type: "DoAnything"
end
```

To define dependencies between workflow steps, pass the `depends_on` argument with an array of step **names** (not class names).

```ruby
workflow do
    step :my_step
    
    step :your_step,
         depends_on: [:my_step]
end
```

### Migrating

Whenever a workflow is executed, workflow and workflow steps are created in the database.
This also means that when you make changes to the workflow, you need to make sure they are either backwards compatible, you migrate (or delete) existing (not complete) workflow and workflow step records, or use a versioning strategy for your workflows.
Not doing this could lead to inconsistencies, such as missing steps in the workflow, errors trying to execute a step that no longer exists, or others.
The records are persisted in the STI-aware `workflows` and `workflow_steps` tables.
The workflow records persist the state, and type (class name) of the workflow.
The workflow step records persist the state, type (class name), and (unique) name of the workflow step.
See [`spec/dummy/db/schema.rb`](spec/dummy/db/schema.rb) for the table schema.

```ruby
module VideoProcessingWorkflow
  class V1 < Workflows::Workflow
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
```

## Testing

The gem includes a minimal Rails dummy app in `spec/dummy/` for integration testing.

### Setup

```bash
cd spec/dummy
bundle install
bundle exec rails db:create db:migrate
```

### Running specs

From the gem root:

```bash
bundle exec rspec
```

## Releasing

To release a new version, update the version number in `lib/workflows/version.rb`, update the changelog, commit the files and create a git tag starting with `v`, and push it to the repository.
Github Actions will automatically run the test suite, build the `.gem` file and push it to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/floriandejonckheere/workflows](https://github.com/floriandejonckheere/workflows). 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
