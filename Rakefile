# Available Rake Tasks:
# - test: Run RSpec tests
# - lint: Run RuboCop to lint and check for style violations
# - autocorrect: Run RuboCop with safe autocorrection
# - build: Build the gem package
# - release: Release the gem to RubyGems
# - clean: Clean up generated files
# - reinstall_dependencies: Clean and reinstall all gems
# - demo:build: Build the Jekyll demo site
# - demo:serve: Serve the Jekyll demo site
# - plugin:build: Build the gem for the plugin
# - plugin:publish: Publish the plugin to RubyGems
# - plugin:yank: Yank a specific version of the gem from RubyGems

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "fileutils"

# Task for running tests
RSpec::Core::RakeTask.new(:spec)

# Default task (runs tests)
task default: :spec

# Task for linting with RuboCop
desc "Run RuboCop lint checks"
task :lint do
  sh "bundle exec rubocop"
end

# Task for RuboCop autocorrection
desc "Run RuboCop with safe autocorrection"
task :autocorrect do
  puts "Running RuboCop with safe autocorrection..."
  sh "bundle exec rubocop -a"
  puts "Safe autocorrection completed."
end

desc 'Clean up gem installations and demo/_site folder'
task :clean do
  sh 'gem cleanup'

  site_dir = 'demo/_site'
  if File.exist?(site_dir)
    puts "Removing directory: #{site_dir}"
    FileUtils.rm_rf(site_dir)
  else
    puts "Directory not found, skipped removing it: #{site_dir}"
  end
end

    namespace :demo do
      desc "Build the Jekyll demo site"
      task :build do
        safely_in_demo_dir do
          sh "bundle install"
          sh "bundle exec jekyll build"
        end
      end
    
      desc "Serve the Jekyll demo site locally"
      task :serve do
        safely_in_demo_dir do
          sh "bundle install"
          sh "bundle exec jekyll serve"
        end
      end
    end
    

namespace :plugin do
  desc "Build the gem package"
  task :build do
    sh "gem build jekyll-sketchviz.gemspec"
  end

  desc "Release the gem to RubyGems"
  task :publish do
    puts "Do you really want to publish the gem? (y/n)"
    input = STDIN.gets.chomp.downcase
    if input == "y"
      sh "gem push jekyll-sketchviz-*.gem"
    else
      puts "Publish aborted."
    end
  end

  desc "Yank the gem from RubyGems"
  task :yank do
    puts "Do you really want to yank the latest gem version? (y/n)"
    input = STDIN.gets.chomp.downcase
    if input == "y"
      sh "gem yank jekyll-sketchviz"
    else
      puts "Yank aborted."
    end
  end
end

# Helper method to execute commands in the demo directory
def safely_in_demo_dir
  demo_dir = File.join(Dir.pwd, "demo")
  raise "Demo directory not found: #{demo_dir}" unless Dir.exist?(demo_dir)

  # Set the Gemfile path explicitly for Bundler,
  # otherwise when executed through `rake` it will still use parent folder files.
  ENV['BUNDLE_GEMFILE'] = File.join(demo_dir, "Gemfile")

  Dir.chdir(demo_dir) do
    yield
  end
ensure
  # Reset the Gemfile path after execution
  ENV.delete('BUNDLE_GEMFILE')
end
