# frozen_string_literal: true

require_relative "lib/workflows/version"

Gem::Specification.new do |spec|
  spec.name          = "workflows"
  spec.version       = Workflows::VERSION
  spec.authors       = ["Florian Dejonckheere"]
  spec.email         = ["florian@floriandejonckheere.be"]

  spec.summary       = "Workflow orchestration framework"
  spec.description   = "Workflow orchestration framework for Rails background processing jobs"
  spec.homepage      = "https://github.com/floriandejonckheere/workflows"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 4.0")

  spec.metadata["source_code_uri"] = "https://github.com/floriandejonckheere/workflows.git"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["README.md", "LICENSE.md", "CHANGELOG.md", "Gemfile", "lib/**/*.rb", "config/*.rb"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"
  spec.add_dependency "zeitwerk"
end
