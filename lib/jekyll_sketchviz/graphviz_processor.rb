# frozen_string_literal: true

require 'fileutils'
require 'pathname'

# The JekyllSketchviz module encapsulates all functionality
# related to the Sketchviz plugin for Jekyll.
module JekyllSketchviz
  # GraphvizProcessor handles the processing of `.dot` files
  # into `.svg` files using user-defined or default configurations.
  class GraphvizProcessor
    # Processes a given `.dot` file and generates an `.svg` output.
    #
    # @param dot_file_path [String] The path to the `.dot` file being processed.
    # @param output_base_dir [String] The base directory for the generated `.svg` file.
    # @param input_base_dir [String] The base directory for input `.dot` files.
    # @return [String, nil] The path to the generated `.svg` file or `nil` if processing fails.
    def process(dot_file_path, output_base_dir, input_base_dir)
      input_base_dir = File.expand_path(input_base_dir)
      output_path = build_output_path(dot_file_path, output_base_dir, input_base_dir)

      ensure_output_directory_exists(output_path)

      generate_svg(dot_file_path, output_path)
    end

    private

    # Builds the output path for the `.svg` file based on the input `.dot` file path.
    #
    # @param dot_file_path [String] The path to the `.dot` file being processed.
    # @param output_base_dir [String] The base directory for the generated `.svg` file.
    # @param input_base_dir [String] The base directory for input `.dot` files.
    # @return [String] The path to the generated `.svg` file.
    def build_output_path(dot_file_path, output_base_dir, input_base_dir)
      relative_path = Pathname.new(dot_file_path).relative_path_from(Pathname.new(input_base_dir)).to_s
      File.join(output_base_dir, relative_path.sub(/\.dot$/, '.svg'))
    end

    # Ensures the output directory for the `.svg` file exists.
    #
    # @param output_path [String] The path to the `.svg` file being generated.
    def ensure_output_directory_exists(output_path)
      dir_path = File.dirname(output_path)
      FileUtils.mkdir_p(dir_path)

      return if File.directory?(dir_path)

      Jekyll.logger.error 'GraphvizProcessor:', "Failed to create directory: #{dir_path}"
      raise IOError, "Output directory creation failed: #{dir_path}"
    end

    # Generates the `.svg` file for a given `.dot` file.
    #
    # @param dot_file_path [String] The path to the `.dot` file being processed.
    # @param output_path [String] The path to the `.svg` file being generated.
    def generate_svg(dot_file_path, output_path)
      Jekyll.logger.info 'GraphvizProcessor:', "Processing file: #{dot_file_path}"
      File.write(output_path, '<svg><!-- Mock SVG content --></svg>')
      Jekyll.logger.info 'GraphvizProcessor:', "Output written to: #{output_path}"
    end
  end
end
