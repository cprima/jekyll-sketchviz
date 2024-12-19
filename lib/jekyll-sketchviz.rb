require 'jekyll'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'

require_relative 'jekyll-sketchviz/version'

# Require all Ruby files in 'lib/', except this file
Dir[File.join(__dir__, '*.rb')].each do |file|
  require file unless file.end_with?('/jekyll-sketchviz.rb')
end

# Write the code for your gem here
