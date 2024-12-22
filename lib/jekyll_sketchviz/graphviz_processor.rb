# frozen_string_literal: true

require 'open3'

# The JekyllSketchviz module encapsulates all functionality
# related to the Sketchviz plugin for Jekyll.
module JekyllSketchviz
  # GraphvizProcessor handles the processing of `.dot` files
  # into `.svg` files using user-defined or default configurations.
  class GraphvizProcessor
    def process(dot_file_path, output_base_dir, input_base_dir, dot_executable)
      # Construct the output file path relative to the input base directory
      relative_path = Pathname.new(dot_file_path).relative_path_from(Pathname.new(input_base_dir)).to_s
      output_path = File.join(output_base_dir, relative_path.sub(/\.dot$/, '.svg'))

      # Log the paths for debugging
      Jekyll.logger.debug 'GraphvizProcessor:', "dot_file_path: #{dot_file_path}"
      Jekyll.logger.debug 'GraphvizProcessor:', "output_path: #{output_path}"
      Jekyll.logger.debug 'GraphvizProcessor:', "input_base_dir: #{input_base_dir}"

      # Ensure the output directory exists
      ensure_output_directory_exists(output_path)

      # Process the content
      content = read_and_strip_frontmatter(dot_file_path)
      execute_dot_with_content(content, output_path, dot_executable)
    end


    private

    def read_and_strip_frontmatter(dot_file_path)
      content = File.read(dot_file_path)
      Jekyll.logger.debug 'GraphvizProcessor:', "Original content of #{dot_file_path}:\n#{content}"

      # Enhanced frontmatter detection and stripping
      stripped_content = content.sub(/\A---\s*\n(?:---\s*\n)?/, '').strip

      raise "Content is empty after stripping frontmatter: #{dot_file_path}" if stripped_content.empty?

      Jekyll.logger.debug 'GraphvizProcessor:', "Stripped content of #{dot_file_path}:\n#{stripped_content}"
      stripped_content
    rescue StandardError => e
      Jekyll.logger.error 'GraphvizProcessor:',
                          "Error reading or stripping frontmatter from #{dot_file_path}: #{e.message}"
      raise
    end

    def ensure_output_directory_exists(output_path)
      dir_path = File.dirname(output_path)
      FileUtils.mkdir_p(dir_path)

      unless File.directory?(dir_path)
        Jekyll.logger.error 'GraphvizProcessor:', "Failed to create directory: #{dir_path}"
        raise IOError, "Output directory creation failed: #{dir_path}"
      end
    rescue StandardError => e
      Jekyll.logger.error 'GraphvizProcessor:', "Error ensuring directory exists: #{e.message}"
      raise
    end

    def execute_dot_with_content(content, output_path, dot_executable)
      Open3.popen3(dot_executable, '-Tsvg', '-o', output_path) do |stdin, _stdout, stderr, wait_thr|
        stdin.write(content)
        stdin.close

        unless wait_thr.value.success?
          Jekyll.logger.error 'GraphvizProcessor:', "Error processing content: #{stderr.read}"
        end
      end
    rescue StandardError => e
      Jekyll.logger.error 'GraphvizProcessor:', "Unexpected error: #{e.message}"
    end
  end
end
