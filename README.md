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
This method takes no arguments.

```ruby
workflow do
  # ...
end
```

### Steps

Define an abstract step inside your abstract workflow by calling the `step` method.

```ruby
step :my_step
```

The step class name is automatically inferred from the step name.
To override this, pass the `class_name` argument.

```ruby
step :my_step,
     type: "YourStep"
```

To define dependencies between workflow steps, pass the `depends_on` argument with an array of step **names** (not class names).

```ruby
step :my_step

step :your_step,
     depends_on: [:my_step]
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
