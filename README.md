# Workflows

![Continuous Integration](https://github.com/floriandejonckheere/workflows/actions/workflows/ci.yml/badge.svg)
![Release](https://img.shields.io/github/v/release/floriandejonckheere/workflows?label=Latest%20release)

Workflow orchestration framework for Ruby on Rails background processing jobs.

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

```ruby
require "workflows"
```

## Testing

The gem includes a minimal Rails dummy app in `spec/dummy/` for integration testing.

### Setup

```bash
cd test/dummy
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
