# frozen_string_literal: true

require 'jekyll_sketchviz/generator'

# Tests for JekyllSketchviz::Generator class
RSpec.describe JekyllSketchviz::Generator do
  subject(:generator) { described_class.new }

  let(:mock_config) do
    {
      input_collection: 'graphs',
      output: { filesystem: { path: 'assets/graphs' } }
    }
  end

  let(:mock_site) do
    instance_double(
      Jekyll::Site,
      collections: { 'graphs' => mock_collection },
      config: { 'sketchviz' => mock_config },
      source: '/mock/site/source',
      dest: '/mock/site/_site'
    )
  end

  let(:mock_processor) { instance_double(JekyllSketchviz::GraphvizProcessor) }
  let(:mock_collection) { instance_double(Jekyll::Collection, docs: dot_documents) }
  let(:dot_documents) do
    [
      instance_double(Jekyll::Document, path: 'spec/mock_files/example01.dot'),
      instance_double(Jekyll::Document, path: 'spec/mock_files/example02.dot')
    ]
  end

  before do
    allow(JekyllSketchviz::GraphvizProcessor).to receive(:new).and_return(mock_processor)
    allow(mock_processor).to receive(:process)
    allow(mock_site.collections).to receive(:[]).with('graphs').and_return(mock_collection)
    allow(Jekyll::Hooks).to receive(:register).and_yield(mock_site)
  end

  describe '#generate' do
    it 'detects the specified collection' do
      generator.generate(mock_site)
      expect(mock_site.collections).to have_received(:[]).with('graphs')
    end

    it 'processes individual .dot files' do
      generator.generate(mock_site)
      expect(mock_processor).to have_received(:process).with(
        'spec/mock_files/example01.dot',
        '/mock/site/_site/assets/graphs',
        '/mock/site/source/_graphs'
      )
      expect(mock_processor).to have_received(:process).with(
        'spec/mock_files/example02.dot',
        '/mock/site/_site/assets/graphs',
        '/mock/site/source/_graphs'
      )
    end

    it 'processes all .dot files in the collection' do
      generator.generate(mock_site)
      dot_documents.each do |doc|
        expect(mock_processor).to have_received(:process).with(
          doc.path,
          '/mock/site/_site/assets/graphs',
          '/mock/site/source/_graphs'
        )
      end
    end
  end
end
