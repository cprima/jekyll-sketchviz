require 'nokogiri'

module JekyllSketchviz
  module Utilities
    class RoughSVGIdentifier
      # Main method to identify rough SVG
      # Params:
      # - input1: First SVG input (path or content)
      # - input2: Second SVG input (path or content)
      # - type: :path or :content to specify input type
      # - debug: Boolean flag for debug output
      def self.identify(input1, input2, type: :path, debug: false)
        errors = validate_inputs(input1, input2, type)
        return { isValid: false, status: "Invalid", errors: errors } if errors.any?

        svg1, svg2 = load_svgs(input1, input2, type)

        analyze_svg(svg1, svg2, debug: debug)
      end

      private_class_method

      # Validate the inputs based on their type
      def self.validate_inputs(input1, input2, type)
        errors = []
        if type == :path
          errors << "File not found: #{input1}" unless File.exist?(input1)
          errors << "File not found: #{input2}" unless File.exist?(input2)
        elsif type != :content
          errors << "Invalid type: #{type}. Allowed types are :path or :content."
        end
        errors
      end

      # Load SVG content based on type
      def self.load_svgs(input1, input2, type)
        if type == :path
          svg1 = File.read(input1)
          svg2 = File.read(input2)
        else
          svg1 = input1
          svg2 = input2
        end
        [svg1, svg2]
      end

      # Analyze the SVGs and determine which one is rough
      def self.analyze_svg(svg1, svg2, debug: false)
        svg_namespace = { "svg" => "http://www.w3.org/2000/svg" }
        parsed_svg1 = Nokogiri::XML(svg1) { |config| config.noblanks }
        parsed_svg2 = Nokogiri::XML(svg2) { |config| config.noblanks }

        element_types = %w[g polygon path text]
        counts1 = {}
        counts2 = {}

        element_types.each do |element|
          counts1[element] = parsed_svg1.xpath("//svg:#{element}", svg_namespace).count
          counts2[element] = parsed_svg2.xpath("//svg:#{element}", svg_namespace).count
        end

        decision = if counts1['path'] > counts2['path'] && counts1['polygon'] < counts2['polygon']
          { rough: type == :content ? 'input1' : input1, simple: type == :content ? 'input2' : input2 }
        elsif counts2['path'] > counts1['path'] && counts2['polygon'] < counts1['polygon']
          { rough: type == :content ? 'input2' : input2, simple: type == :content ? 'input1' : input1 }
        else
          { rough: nil, simple: nil, reason: 'Indeterminate' }
        end


        if debug
          puts "Counts for Input 1: #{counts1}"
          puts "Counts for Input 2: #{counts2}"
          puts "Decision: #{decision}"
        end

        {
          isValid: true,
          status: "Processed",
          counts: { input1: counts1, input2: counts2 },
          result: decision
        }
      rescue Nokogiri::XML::SyntaxError => e
        {
          isValid: false,
          status: "Invalid",
          errors: ["Invalid SVG content: #{e.message}"]
        }
      end
    end
  end
end
