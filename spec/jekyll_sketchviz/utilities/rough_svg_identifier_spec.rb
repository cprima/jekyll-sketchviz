require 'nokogiri'
require_relative '../../../lib/jekyll_sketchviz/utilities/rough_svg_identifier'

RSpec.describe JekyllSketchviz::Utilities::RoughSVGIdentifier do
  let(:simple_svg_path) { 'spec/mock_files/simple_rectangle_graph.svg' }
  let(:rough_svg_path) { 'spec/mock_files/rough_rectangle_graph.svg' }

  let(:simple_svg_content) { '<svg><rect /></svg>' }
  let(:rough_svg_content) { '<svg><path /><path /></svg>' }

  before do
    allow(File).to receive(:exist?).with(simple_svg_path).and_return(true)
    allow(File).to receive(:exist?).with(rough_svg_path).and_return(true)
    allow(File).to receive(:read).with(simple_svg_path).and_return(simple_svg_content)
    allow(File).to receive(:read).with(rough_svg_path).and_return(rough_svg_content)
  end

  describe '.identify' do
    context 'when provided with valid file paths' do
      it 'correctly identifies the rough and simple SVGs' do
        result = described_class.identify(simple_svg_path, rough_svg_path, type: :path)

        expect(result[:isValid]).to be true
        expect(result[:status]).to eq('Processed')
        expect(result[:result][:rough]).to eq(rough_svg_path)
        expect(result[:result][:simple]).to eq(simple_svg_path)
        expect(result[:result][:reason]).to include('More paths and fewer polygons')
      end
    end

    context 'when provided with SVG content directly' do
      it 'correctly identifies the rough and simple SVGs' do
        result = described_class.identify(simple_svg_content, rough_svg_content, type: :content)
      
        expect(result[:isValid]).to be true
        expect(result[:result][:rough]).to eq('input2')
        expect(result[:result][:simple]).to eq('input1')
      end
      
    end

    context 'when one of the file paths does not exist' do
      it 'returns an error for a missing file' do
        allow(File).to receive(:exist?).with(simple_svg_path).and_return(false)

        result = described_class.identify(simple_svg_path, rough_svg_path, type: :path)

        expect(result[:isValid]).to be false
        expect(result[:errors]).to include("File not found: #{simple_svg_path}")
      end
    end

    context 'when provided invalid type' do
      it 'returns an error for invalid type' do
        result = described_class.identify(simple_svg_path, rough_svg_path, type: :invalid_type)

        expect(result[:isValid]).to be false
        expect(result[:errors]).to include('Invalid type: invalid_type. Allowed types are :path or :content.')
      end
    end

    context 'when comparing invalid SVG content' do
      it 'handles invalid SVG gracefully' do
        invalid_svg_content = '<svg><invalid></svg>'

        result = described_class.identify(simple_svg_content, invalid_svg_content, type: :content)

        expect(result[:isValid]).to be false
        expect(result[:errors].first).to include('Invalid SVG content')
      end
    end
  end
end
