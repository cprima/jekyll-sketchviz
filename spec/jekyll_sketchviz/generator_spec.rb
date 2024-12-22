# frozen_string_literal: true

require 'jekyll'
require 'jekyll_sketchviz/configuration'
require 'jekyll_sketchviz/generator'
require 'jekyll_sketchviz/graphviz_processor'

require 'spec_helper'

RSpec.describe JekyllSketchviz::Generator do
  let(:mock_config) do
    {
      'input_collection' => 'graphs',
      'output' => { 'filesystem' => { 'path' => 'assets/graphs' } },
      'executable' => { 'dot' => 'dot' }
    }
  end

  let(:mock_site) do
    instance_double(
      Jekyll::Site,
      source: 'spec/mock_files',
      dest: 'spec/mock_files/_site',
      config: { 'sketchviz' => mock_config }
    )
  end

  describe '#generate_debug' do
    context 'with a valid site and collection' do
      let(:example_doc_one) { instance_double(Jekyll::Document, path: 'spec/mock_files/example01.dot') }
      let(:example_doc_two) { instance_double(Jekyll::Document, path: 'spec/mock_files/example02.dot') }

      it 'returns debug information with document processing results' do
        mock_collection = instance_double(
          Jekyll::Collection,
          docs: [example_doc_one, example_doc_two]
        )

        allow(mock_site).to receive(:collections).and_return({ 'graphs' => mock_collection })

        processor = instance_double(JekyllSketchviz::GraphvizProcessor)
        allow(JekyllSketchviz::GraphvizProcessor).to receive(:new).and_return(processor)
        allow(processor).to receive(:process).and_return('Simulated processing output')

        generator = described_class.new
        debug_info = generator.generate_debug(mock_site)

        expect(debug_info[:site_source]).to eq('spec/mock_files')
        expect(debug_info[:site_dest]).to eq('spec/mock_files/_site')
        expect(debug_info[:collections]['graphs'][:docs_info]).to contain_exactly(
          a_hash_including(path: 'spec/mock_files/example01.dot', processed: true),
          a_hash_including(path: 'spec/mock_files/example02.dot', processed: true)
        )
      end
    end

    context 'with an empty collection' do
      it 'returns debug information without documents' do
        empty_collection = instance_double(Jekyll::Collection, docs: [])
        allow(mock_site).to receive(:collections).and_return({ 'graphs' => empty_collection })

        generator = described_class.new
        debug_info = generator.generate_debug(mock_site)

        expect(debug_info[:collections]['graphs'][:docs_info]).to be_empty
      end
    end
  end

  describe '#process_graph_files' do
    it 'processes individual graph files' do
      processor = instance_spy(JekyllSketchviz::GraphvizProcessor)
      allow(JekyllSketchviz::GraphvizProcessor).to receive(:new).and_return(processor)

      doc_one_path = 'spec/mock_files/example01.dot'
      doc_two_path = 'spec/mock_files/example02.dot'
      output_base_dir = 'output_path'
      input_base_dir = 'input_path'
      dot_executable = 'dot'

      processor.process(doc_one_path, output_base_dir, input_base_dir, dot_executable)
      processor.process(doc_two_path, output_base_dir, input_base_dir, dot_executable)

      expect(processor).to have_received(:process).with(doc_one_path, output_base_dir, input_base_dir,
                                                        dot_executable).once
      expect(processor).to have_received(:process).with(doc_two_path, output_base_dir, input_base_dir,
                                                        dot_executable).once
    end
  end
end
