# frozen_string_literal: true

require 'jekyll'
require 'jekyll_sketchviz/configuration'
require 'jekyll_sketchviz/graphviz_processor'

# The JekyllSketchviz module encapsulates all functionality
# related to the Sketchviz plugin for Jekyll.
module JekyllSketchviz
  # JekyllSketchviz::Generator integrates with Jekyll's build process
  # to process Graphviz `.dot` files in a user-specified collection,
  # generating styled or unstyled SVG outputs based on configuration.
  class Generator < Jekyll::Generator
    def generate(site)
      # Fetch configuration
      config = JekyllSketchviz::Configuration.from_site(site)

      Jekyll::Hooks.register :site, :post_write do |_post_write_site|
        process_collection_files(site, config)
      end
    end

    private

    def process_collection_files(site, config)
      input_base_dir = build_input_base_dir(site, config)
      output_base_dir = build_output_base_dir(site, config)

      process_files_in_collection(site, config, input_base_dir, output_base_dir)
    end

    def build_input_base_dir(site, config)
      File.join(site.source, "_#{config[:input_collection]}")
    end

    def build_output_base_dir(site, config)
      output_path = Pathname.new(config[:output][:filesystem][:path]).cleanpath.to_s
      File.join(site.dest, output_path)
    end

    def process_files_in_collection(site, config, input_base_dir, output_base_dir)
      Jekyll.logger.debug 'Generator:', "Output base directory: #{output_base_dir}"
      collection = site.collections[config[:input_collection]]
      return unless collection

      dot_executable = config[:executable][:dot] # Fetch the `dot` executable from the configuration

      collection.docs.each do |doc|
        process_document(doc, output_base_dir, input_base_dir, dot_executable)
      end
    end

    # Processes a single `.dot` document.
    #
    # @param doc [Jekyll::Document] The document being processed.
    # @param output_base_dir [String] The base directory for the generated `.svg` file.
    # @param input_base_dir [String] The base directory for input `.dot` files.
    # @param dot_executable [String] The path to the `dot` executable.
    def process_document(doc, output_base_dir, input_base_dir, dot_executable)
      return unless doc.path.end_with?('.dot')

      processor = JekyllSketchviz::GraphvizProcessor.new
      processor.process(doc.path, output_base_dir, input_base_dir, dot_executable)
    end
  end
end
