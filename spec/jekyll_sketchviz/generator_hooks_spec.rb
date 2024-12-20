# frozen_string_literal: true

require 'jekyll'
require 'jekyll/hooks'
require 'jekyll_sketchviz/generator'

RSpec.describe JekyllSketchviz::Generator, '#hooks' do
  let(:mock_config) do
    { 'input_collection' => 'graphs', 'output' => { 'filesystem' => { 'path' => 'assets/graphs' } } }
  end

  let(:mock_site) do
    instance_double(
      Jekyll::Site,
      source: '/mock/site/source',
      dest: '/mock/site/_site',
      config: { 'sketchviz' => mock_config },
      collections: {}
    )
  end

  let(:generator) { described_class.new }

  before do
    allow(generator).to receive(:process_collection_files)
  end

  describe 'Jekyll Hooks' do
    it 'registers the :site, :post_write hook' do
      # Simulate calling the generate method
      generator.generate(mock_site)

      # Trigger the post_write hook explicitly
      Jekyll::Hooks.trigger(:site, :post_write, mock_site)

      # Check if the process_collection_files was called
      expect(generator).to have_received(:process_collection_files).with(mock_site, any_args)
    end
  end
end
