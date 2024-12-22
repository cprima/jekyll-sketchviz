# Gems required for the plugin
source "https://rubygems.org"

gem "jekyll", "~> 4.0"              # Jekyll core for testing integration
gem "nokogiri", "~> 1.12"           # For parsing and modifying SVGs
gem "csv"
gem "base64"



# The jekyll-sketchviz gem dependencies are defined in jekyll-sketchviz.gemspec
gemspec

# Gems for development and testing
group :development, :test do
  gem "rspec", "~> 3.12"            # For writing and running tests
  gem "rubocop", "~> 1.60", require: false # For linting and enforcing code style
  gem "rubocop-rake", require: false       # RuboCop rules for Rake tasks
  gem "rubocop-rspec", require: false      # RuboCop rules for RSpec tests
  gem "rake", "~> 13.0"             # For task automation during development
end

# Gems for packaging and releasing the plugin
group :development do
  gem "rake-compiler", "~> 1.2"     # For building gem packages
  gem "rake-release", "~> 1.1"      # For automating releases to RubyGems
end
