# Available Rake Tasks:
# - project:spec: Run RSpec tests
# - project:lint: Run RuboCop to lint and check for style violations
# - project:autocorrect: Run RuboCop with safe autocorrection
# - plugin:build: Build the gem package
# - plugin:publish: Publish the gem to RubyGems
# - plugin:yank: Yank the gem from RubyGems
# - clean:site: Clean the demo/_site folder
# - clean:gems: Clean up gem installations
# - demo:build: Build the Jekyll demo site
# - demo:serve: Serve the Jekyll demo site locally

require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'

# Namespace for project-related tasks
namespace :project do
  desc "Run RSpec tests"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--format documentation'
  end

  desc "Run RuboCop lint checks"
  task :lint do
    sh "bundle exec rubocop"
  end

  desc "Run RuboCop with safe autocorrection"
  task :autocorrect do
    sh "bundle exec rubocop --safe -a"
  end
end

# Namespace for cleaning tasks
namespace :clean do
  desc "Clean demo/_site folder"
  task :site do
    site_dir = 'demo/_site'
    if File.exist?(site_dir)
      puts "Removing directory: #{site_dir}"
      FileUtils.rm_rf(site_dir)
    else
      puts "Directory not found, skipped removing it: #{site_dir}"
    end
  end

  desc "Clean up gem installations"
  task :gems do
    sh 'gem cleanup'
  end
end

# Namespace for demo-related tasks
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

# Namespace for plugin-related tasks
namespace :plugin do
  desc "Build the gem package"
  task :build do
    sh "gem build jekyll-sketchviz.gemspec"
  end

  desc "Publish the gem to RubyGems"
  task :publish do
    puts "Do you really want to publish the gem? (y/n)"
    input = STDIN.gets.chomp.downcase
    sh "gem push jekyll-sketchviz-*.gem" if input == "y"
  end

  desc "Yank the gem from RubyGems"
  task :yank do
    puts "Do you really want to yank the latest gem version? (y/n)"
    input = STDIN.gets.chomp.downcase
    sh "gem yank jekyll-sketchviz" if input == "y"
  end
end

# Helper for safely running commands in the demo directory
def safely_in_demo_dir
  demo_dir = File.join(Dir.pwd, 'demo')
  raise "Demo directory not found: #{demo_dir}" unless Dir.exist?(demo_dir)

  ENV['BUNDLE_GEMFILE'] = File.join(demo_dir, 'Gemfile')
  Dir.chdir(demo_dir) { yield }
ensure
  ENV.delete('BUNDLE_GEMFILE')
end

# Default task
task default: 'project:spec'
