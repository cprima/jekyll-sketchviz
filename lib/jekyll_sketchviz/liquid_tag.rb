# frozen_string_literal: true

require 'json'

module JekyllSketchviz
  # Shared behavior for Sketchviz tags
  module SketchvizTagBase
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      site = context.registers[:site]
      config = JekyllSketchviz::Configuration.from_site(site)

      # Parse the tag parameters and merge them into the configuration
      tag_params = parse_tag_parameters(@markup)
      merged_config = JekyllSketchviz::Configuration.deep_merge(config, tag_params)

      render_output(merged_config, @markup)
    end

    def parse_tag_parameters(markup)
      params = markup.split(',', 2)
      file_name = extract_file_name(params)
      options = extract_options(params)
      options[:file_name] = file_name
      options
    end

    private

    def extract_file_name(params)
      params[0].strip.tr('"', '')
    end

    def extract_options(params)
      return {} unless params[1]

      parse_key_value_pairs(params[1].strip)
    end

    def parse_key_value_pairs(option_string)
      pairs = option_string.split(',')
      pairs.each_with_object({}) do |pair, hash|
        key, value = split_key_value(pair)
        hash[key.to_sym] = convert_value(value)
      end
    end

    def split_key_value(pair)
      key, value = pair.split(':', 2).map(&:strip)
      validate_key_value(pair, key, value)
      [key, value]
    end

    def validate_key_value(pair, key, value)
      raise ArgumentError, "Malformed parameter: #{pair.inspect} (missing key)" if key.nil? || key.empty?
      raise ArgumentError, "Malformed parameter: #{pair.inspect} (missing value)" if value.nil? || value.empty?
    end

    def convert_value(value)
      case value
      when 'true' then true
      when 'false' then false
      when /^\d+\.\d+$/ then value.to_f
      when /^\d+$/ then value.to_i
      else
        parse_string_value(value)
      end
    end

    def parse_string_value(value)
      raise ArgumentError, "Invalid value format: #{value.inspect}" unless valid_json_value?(value)

      value.strip.tr('"', '')
    end

    def valid_json_value?(value)
      JSON.parse(value)
      true
    rescue JSON::ParserError
      false
    end

    # Placeholder method to be implemented in subclasses
    def render_output(merged_config, markup)
      raise NotImplementedError, 'Subclasses must implement the render_output method'
    end
  end

  # Debug tag for Sketchviz
  class SketchvizDebugTag < Liquid::Tag
    include SketchvizTagBase

    private

    def render_output(merged_config, markup)
      "Sketchviz Configuration: #{merged_config.inspect}\nTag Parameters: #{markup}"
    end
  end

  # Main Sketchviz tag
  class SketchvizTag < Liquid::Tag
    include SketchvizTagBase
  
    def render(context)
      site = context.registers[:site]
      config = JekyllSketchviz::Configuration.from_site(site)
  
      # Merge tag parameters with the configuration
      tag_params = parse_tag_parameters(@markup)
      merged_config = JekyllSketchviz::Configuration.deep_merge(config, tag_params)
  
      # Call render_output with context
      render_output(merged_config, context)
    end
  
    private
  
    def render_output(merged_config, context)
      # Extract the file name from the configuration
      file_name = merged_config[:file_name]
      raise ArgumentError, "Missing file name in Sketchviz tag" if file_name.nil? || file_name.empty?
    
      # Locate the file on the filesystem
      site_source = context.registers[:site].source
      input_base_dir = File.join(site_source, "_#{merged_config[:input_collection]}")
      file_path = File.join(input_base_dir, file_name)
      raise IOError, "File not found: #{file_path}" unless File.exist?(file_path)
    
      # Generate the SVG content
      processor = JekyllSketchviz::GraphvizProcessor.new
      dot_content = processor.read_and_strip_frontmatter(file_path)
      raw_svg_content = processor.generate_svg(dot_content, merged_config[:executable][:dot])
    
      # Clean the SVG content
      svg_content = processor.clean_svg_content(raw_svg_content)
    
      # Return the cleaned SVG content wrapped in a div for inline rendering
      css_class = merged_config[:output][:inline][:css_classes][:svg]
      "<div class='#{css_class}'>#{svg_content}</div>"
    rescue StandardError => e
      Jekyll.logger.error "SketchvizTag:", "Error rendering diagram: #{e.message}"
      "<div class='error'>Error rendering Sketchviz diagram: #{e.message}</div>"
    end
    
  end
  
  
end

# Register Liquid tags
Liquid::Template.register_tag('sketchviz_debug', JekyllSketchviz::SketchvizDebugTag)
Liquid::Template.register_tag('sketchviz', JekyllSketchviz::SketchvizTag)
