# frozen_string_literal: true

Dir[File.expand_path("../factories/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
