require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Task for running tests
RSpec::Core::RakeTask.new(:spec)

# Default task (runs tests)
task default: :spec

# Task for linting with RuboCop
desc "Run RuboCop lint checks"
task :rubocop do
  sh "bundle exec rubocop"
end
