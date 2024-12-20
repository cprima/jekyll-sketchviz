# frozen_string_literal: true

require 'jekyll' # Ensure Jekyll core is loaded
require_relative 'jekyll_sketchviz/version'
require_relative 'jekyll_sketchviz/configuration'
require_relative 'jekyll_sketchviz/generator'
require_relative 'jekyll_sketchviz/liquid_tag'

# Define the main module for the plugin
module JekyllSketchviz
  # This ensures the plugin is registered and functional when included in a Jekyll site
  Jekyll::Hooks.register :site, :post_write do |site|
    config = Configuration.from_site(site)
    Jekyll.logger.info 'Jekyll Sketchviz:', "Loaded configuration: #{config.inspect}"
  end
end
