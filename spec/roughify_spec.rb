require 'open3'
require 'nokogiri'
require_relative '../lib/jekyll_sketchviz/utilities/rough_svg_identifier'

RSpec.describe 'Roughify Script' do
  let(:node_script) { 'node lib/scripts/roughify.js' } # Adjust path if needed

  let(:input_svg_path_01) { 'spec/mock_files/example01.svg' }
  let(:expected_rough_svg_path_01) { 'spec/mock_files/rough_example01.svg' }

  let(:input_svg_path_02) { 'spec/mock_files/example02.svg' }
  let(:expected_rough_svg_path_02) { 'spec/mock_files/rough_example02.svg' }

  context 'when processing example01.svg' do
    it 'generates a roughened SVG that is identified as rough' do
      roughened_output = run_roughify(input_svg_path_01)
      validate_roughened_svg(input_svg_path_01, roughened_output)
    end
  end

  context 'when processing example02.svg' do
    it 'generates a roughened SVG that is identified as rough' do
      roughened_output = run_roughify(input_svg_path_02)
      validate_roughened_svg(input_svg_path_02, roughened_output)
    end
  end

  context 'when no arguments are provided' do
    it 'displays an error and exits' do
      output, error, status = Open3.capture3("#{node_script}")
      expect(status.exitstatus).not_to eq(0)
      expect(error).to include('Usage: roughify.js <path-to-svg>')
    end
  end

  context 'when additional options are passed' do
    it 'applies the roughness and bowing parameters' do
      roughened_output = run_roughify(input_svg_path_01, '--roughness=2', '--bowing=3')
      validate_svg_with_identifier(input_svg_path_01, roughened_output)
    end
  end

  # Helper method to call the Node.js script
  def run_roughify(input_path, *options)
    command = "#{node_script} #{input_path} #{options.join(' ')}"
    output, error, status = Open3.capture3(command)

    raise "Error running roughify: #{error}" unless status.success?
    output
  end

  # Validate roughened SVG using RoughSVGIdentifier
  def validate_svg_with_identifier(original_path, roughened_output)
    identifier = JekyllSketchviz::Utilities::RoughSVGIdentifier
    result = identifier.identify(original_path, roughened_output)

    expect(result[:is_valid]).to eq(true), "Validation failed: #{result[:errors]}"
    expect(result[:result][:rough]).to eq(roughened_output), "Expected the output to be identified as rough"
  end

  # Original validation method for comparison
  def validate_roughened_svg(original_path, roughened_output)
    original_svg = Nokogiri::XML(File.read(original_path))
    rough_svg = Nokogiri::XML(roughened_output)

    original_elements = original_svg.xpath('//circle | //rect | //ellipse | //line | //polygon | //polyline | //path').size
    rough_elements = rough_svg.xpath('//circle | //rect | //ellipse | //line | //polygon | //polyline | //path').size

    original_attributes = original_svg.xpath('//@*').size
    rough_attributes = rough_svg.xpath('//@*').size

    puts "Original elements: #{original_elements}, Roughened elements: #{rough_elements}"
    puts "Original attributes: #{original_attributes}, Roughened attributes: #{rough_attributes}"

    expect(rough_elements).to be >= original_elements
    expect(rough_attributes).to be > original_attributes
  end
end
