# frozen_string_literal: true

require 'open3'
require 'nokogiri'

# The JekyllSketchviz module encapsulates all functionality
# related to the Sketchviz plugin for Jekyll.
module JekyllSketchviz
  # GraphvizProcessor handles the processing of `.dot` files
  # into `.svg` files using user-defined or default configurations.
  class GraphvizProcessor
    def process(dot_file_path, output_base_dir, input_base_dir, dot_executable)
      Jekyll.logger.debug 'GraphvizProcessor:', "Starting process for file: #{dot_file_path}"
      relative_path = relative_dot_path(dot_file_path, input_base_dir)
      output_path = File.join(output_base_dir, relative_path.sub(/\.dot$/, '.svg'))

      log_paths(dot_file_path, output_path, input_base_dir)

      ensure_output_directory_exists(output_path)

      content = read_and_strip_frontmatter(dot_file_path)
      execute_dot_with_content(content, output_path, dot_executable)
    rescue StandardError => e
      log_error("Error processing file #{dot_file_path}", e.message)
      raise
    end

    def generate_svg(dot_content, dot_executable)
      Jekyll.logger.debug 'GraphvizProcessor:', 'Generating SVG from provided DOT content'
      Jekyll.logger.debug 'GraphvizProcessor:', "DOT content:\n#{dot_content}"

      svg_content = execute_dot_with_content(dot_content, nil, dot_executable)
      validate_svg_content(svg_content)

      Jekyll.logger.debug 'GraphvizProcessor:', "Generated SVG content:\n#{svg_content[0..500]}"
      svg_content
    rescue StandardError => e
      log_error('Error generating SVG', e.message)
      raise
    end

    def read_and_strip_frontmatter(dot_file_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Reading file: #{dot_file_path}"
      content = File.read(dot_file_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Original content:\n#{content}"

      stripped_content = strip_frontmatter(content, dot_file_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Stripped content:\n#{stripped_content}"

      stripped_content
    rescue StandardError => e
      log_error("Error reading or stripping frontmatter from #{dot_file_path}", e.message)
      raise
    end

    def validate_svg_content(svg_content)
      raise "SVG content is empty" if svg_content.nil? || svg_content.strip.empty?

      Jekyll.logger.debug 'GraphvizProcessor:', 'Validating SVG content with Nokogiri'
      doc = Nokogiri::XML(svg_content) do |config|
        config.strict.noblanks
      end

      svg_element = doc.at_xpath('//xmlns:svg', 'xmlns' => 'http://www.w3.org/2000/svg')

      Jekyll.logger.debug 'GraphvizProcessor:', "Parsed SVG element: #{svg_element ? svg_element.to_s[0..500] : 'nil'}"
      raise "Generated content does not appear to be an SVG" if svg_element.nil?

      svg_element
    rescue Nokogiri::XML::SyntaxError => e
      log_error("Nokogiri parsing error during SVG validation", e.message)
      raise "Invalid SVG content: #{e.message}"
    end

    def clean_svg_content(svg_content)
      Jekyll.logger.debug 'GraphvizProcessor:', 'Cleaning SVG content'
      doc = Nokogiri::XML(svg_content)
    
      # Adjusted XPath to include namespace handling
      svg_element = doc.at_xpath('//xmlns:svg', 'xmlns' => 'http://www.w3.org/2000/svg')
    
      if svg_element.nil?
        Jekyll.logger.error 'GraphvizProcessor:', "Failed to find <svg> element in content:\n#{svg_content[0..500]}"
        raise "SVG content is missing <svg> element"
      end
    
      Jekyll.logger.debug 'GraphvizProcessor:', "Cleaned SVG content:\n#{svg_element.to_s[0..500]}"
      svg_element.to_s
    end
    

    private

    def relative_dot_path(dot_file_path, input_base_dir)
      Jekyll.logger.debug 'GraphvizProcessor:', 'Calculating relative path'
      Pathname.new(dot_file_path).relative_path_from(Pathname.new(input_base_dir)).to_s
    end

    def log_paths(dot_file_path, output_path, input_base_dir)
      Jekyll.logger.debug 'GraphvizProcessor:', "dot_file_path: #{dot_file_path}"
      Jekyll.logger.debug 'GraphvizProcessor:', "output_path: #{output_path}"
      Jekyll.logger.debug 'GraphvizProcessor:', "input_base_dir: #{input_base_dir}"
    end

    def strip_frontmatter(content, dot_file_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Stripping frontmatter for: #{dot_file_path}"
      stripped_content = content.sub(/\A---\s*\n(?:---\s*\n)?/, '').strip
      raise "Content is empty after stripping frontmatter: #{dot_file_path}" if stripped_content.empty?

      stripped_content
    end

    def ensure_output_directory_exists(output_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Ensuring directory exists for: #{output_path}"
      dir_path = File.dirname(output_path)
      FileUtils.mkdir_p(dir_path)
      validate_directory(dir_path)
    rescue StandardError => e
      log_error("Error ensuring directory exists for #{output_path}", e.message)
      raise
    end

    def validate_directory(dir_path)
      return if File.directory?(dir_path)
      log_error('Failed to create directory', dir_path)
      raise IOError, "Output directory creation failed: #{dir_path}"
    end

    def execute_dot_with_content(content, output_path, dot_executable)
      Jekyll.logger.debug 'GraphvizProcessor:', "Executing DOT command with Graphviz"
      args = build_dot_arguments(output_path, dot_executable)
      run_dot_command(content, args, output_path)
    end

    def build_dot_arguments(output_path, dot_executable)
      Jekyll.logger.debug 'GraphvizProcessor:', "Building DOT command arguments"
      args = [dot_executable, '-Tsvg']
      args += ['-o', output_path] if output_path
      Jekyll.logger.debug 'GraphvizProcessor:', "DOT arguments: #{args.inspect}"
      args
    end

    def run_dot_command(content, args, output_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Running DOT command: #{args.join(' ')}"
      Open3.popen3(*args) do |stdin, stdout, stderr, wait_thr|
        stdin.write(content)
        stdin.close

        stdout_output = stdout.read
        stderr_output = stderr.read

        Jekyll.logger.debug 'GraphvizProcessor:', "DOT stdout:\n#{stdout_output[0..500]}"
        Jekyll.logger.debug 'GraphvizProcessor:', "DOT stderr:\n#{stderr_output}" unless stderr_output.empty?

        if wait_thr.value.success?
          output_path ? nil : stdout_output
        else
          Jekyll.logger.error 'GraphvizProcessor:', "DOT error:\n#{stderr_output}"
          handle_dot_execution_error(stderr_output)
        end
      end
    rescue StandardError => e
      log_error('Unexpected error during DOT execution', e.message)
      raise
    end

    def handle_dot_execution_error(error_message)
      log_error('Error processing DOT content', error_message)
      raise "DOT execution failed: #{error_message}"
    end

    def log_error(message, details)
      Jekyll.logger.error 'GraphvizProcessor:', "#{message}: #{details}"
    end
  end
end
