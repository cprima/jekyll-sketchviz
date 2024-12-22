# frozen_string_literal: true

require 'jekyll'
require 'jekyll_sketchviz/configuration'
require 'jekyll_sketchviz/graphviz_processor'

# The JekyllSketchviz module encapsulates all functionality
# related to the Sketchviz plugin for Jekyll.
module JekyllSketchviz
  # Integrates with Jekyll's build process to process Graphviz `.dot` files
  # in a user-specified collection, generating styled or unstyled SVG outputs
  # based on configuration.
  class Generator < Jekyll::Generator
    # Registers post_write hooks for processing files
    def generate(site)
      config = JekyllSketchviz::Configuration.from_site(site)
      Jekyll.logger.debug 'Generator:', "Fetched configuration: #{config.inspect}"

      Jekyll::Hooks.register :site, :post_write do |_post_write_site|
        Jekyll.logger.debug 'Generator:', 'Triggering post_write hook'
        process_collection_files(site, config)
      end
    end

    # Generates debug information for site collections and documents
    def generate_debug(site)
      config = JekyllSketchviz::Configuration.from_site(site)
      input_base_dir, output_base_dir = setup_base_dirs(site, config)
      collection_debug_info = build_debug_info(site, config, input_base_dir, output_base_dir)

      {
        config: config,
        site_source: site.source,
        site_dest: site.dest,
        input_base_dir: input_base_dir,
        output_base_dir: output_base_dir,
        collections: collection_debug_info
      }
    end

    private

    # Sets up input and output base directories
    def setup_base_dirs(site, config)
      input_base_dir = File.join(site.source, "_#{config[:input_collection]}")
      output_base_dir = File.join(site.dest, config[:output][:filesystem][:path])
      [input_base_dir, output_base_dir]
    end

    # Builds debug information for the collections
    def build_debug_info(site, config, input_base_dir, output_base_dir)
      site.collections.transform_values do |collection|
        build_collection_debug_info(collection, config, input_base_dir, output_base_dir)
      end
    end

    # Builds debug information for an individual collection
    def build_collection_debug_info(collection, config, input_base_dir, output_base_dir)
      docs_info = collection.docs.map { |doc| debug_document(doc, config, input_base_dir, output_base_dir) }.compact
      { docs_count: docs_info.size, docs_info: docs_info }
    end

    # Builds debug information for a single document
    def debug_document(doc, config, input_base_dir, output_base_dir)
      return unless doc.path.end_with?('.dot')

      processor = JekyllSketchviz::GraphvizProcessor.new
      simulated_svg_content = nil

      {
        path: doc.path,
        processed: true,
        processing_output: "#{output_base_dir}/#{File.basename(doc.path, '.dot')}.svg",
        processing_result: process_debug(doc, processor, config, input_base_dir, simulated_svg_content),
        inline_svg: simulated_svg_content
      }
    end

    # Handles document processing for debug mode
    def process_debug(doc, processor, config, input_base_dir, _simulated_svg_content)
      if defined?(mock_processor)
        processor.generate_svg(File.read(doc.path), config[:executable][:dot])
        "Generated inline SVG for #{doc.path}"
      else
        processor.process(doc.path, output_base_dir, input_base_dir, config[:executable][:dot])
        "Processed #{doc.path} successfully"
      end
    rescue StandardError => e
      "Failed to process #{doc.path}: #{e.message}"
    end

    def process_collection_files(site, config)
      input_base_dir, output_base_dir = setup_base_dirs(site, config)

      Jekyll.logger.debug 'Generator:', "Input base directory: #{input_base_dir}"
      Jekyll.logger.debug 'Generator:', "Output base directory: #{output_base_dir}"

      process_files_in_collection(site, config, input_base_dir, output_base_dir)
    end

    def process_files_in_collection(site, config, input_base_dir, output_base_dir)
      collection = site.collections[config[:input_collection]]
      return unless collection

      dot_executable = config[:executable][:dot]

      collection.docs.each do |doc|
        process_document(doc, output_base_dir, input_base_dir, dot_executable)
      end
    end

    # Processes a single `.dot` document
    def process_document(doc, output_base_dir, input_base_dir, dot_executable)
      return unless doc.path.end_with?('.dot')

      Jekyll.logger.debug(
        'Generator: Processing doc: ' \
        "#{doc.path}, Output base dir: #{output_base_dir}, " \
        "Input base dir: #{input_base_dir}, Dot executable: #{dot_executable}"
      )
      

      processor = JekyllSketchviz::GraphvizProcessor.new
      processor.process(doc.path, output_base_dir, input_base_dir, dot_executable)
    end
  end
end
