# frozen_string_literal: true

require 'jekyll'
require 'logger'

# Configure a standard Ruby Logger
STANDARD_LOGGER = Logger.new($stdout) # Log to stdout
STANDARD_LOGGER.level = Logger::DEBUG # Set to DEBUG level for detailed output
# STANDARD_LOGGER.debug 'TestLogger: Debug message from RSpec'

RSpec.configure do |config|
  # config.before(:suite) do
  #   STANDARD_LOGGER.debug 'RSpec: Logger setup complete. Standard logger verified.'
  # end
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Enable verbose output when running individual test files
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Randomize test order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
