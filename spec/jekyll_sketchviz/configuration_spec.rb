# frozen_string_literal: true

require 'jekyll_sketchviz/configuration'

RSpec.describe JekyllSketchviz::Configuration do
  let(:default_config) { JekyllSketchviz::Configuration::DEFAULTS }

  let(:site) do
    instance_double(
      Jekyll::Site,
      config: site_config,
      source: '/mock/site/source' # Mock the `source` method
    )
  end

  let(:site_config) { { 'sketchviz' => user_config } }
  let(:user_config) { nil }

  describe '.from_site' do
    context 'when no user config is provided' do
      let(:user_config) { nil }

      it 'returns the default configuration' do
        result = described_class.from_site(site)
        expect(result).to eq(default_config)
      end
    end

    context 'when a simple override is provided' do
      let(:user_config) { { 'roughness' => 2.0 } }

      it 'overrides the default roughness value' do
        result = described_class.from_site(site)
        expect(result[:roughness]).to eq(2.0)
      end

      it 'preserves the default bowing value' do
        result = described_class.from_site(site)
        expect(result[:bowing]).to eq(default_config[:bowing])
      end
    end

    context 'when a nested override is provided' do
      let(:user_config) do
        { 'output' => { 'inline' => { 'styled' => false } } }
      end

      it 'overrides the nested styled value' do
        result = described_class.from_site(site)
        expect(result[:output][:inline][:styled]).to be(false)
      end

      it 'preserves other nested default values' do
        result = described_class.from_site(site)
        expect(result[:output][:inline][:css_classes]).to eq(default_config[:output][:inline][:css_classes])
      end
    end

    context 'when invalid user configurations are provided' do
      let(:user_config) { { 'roughness' => 'not_a_number' } }

      it 'falls back to the default value' do
        result = described_class.from_site(site)
        expect(result[:roughness]).to eq(default_config[:roughness])
      end
    end

    context 'when a full user configuration is provided' do
      let(:user_config) do
        {
          'input_collection' => 'custom_graphs',
          'roughness' => 2.5,
          'output' => { 'filesystem' => { 'styled' => true } }
        }
      end

      it 'overrides the input_collection value' do
        result = described_class.from_site(site)
        expect(result[:input_collection]).to eq('custom_graphs')
      end

      it 'overrides the roughness value' do
        result = described_class.from_site(site)
        expect(result[:roughness]).to eq(2.5)
      end

      it 'overrides nested filesystem styled value' do
        result = described_class.from_site(site)
        expect(result[:output][:filesystem][:styled]).to be(true)
      end

      it 'preserves nested inline css_classes defaults' do
        result = described_class.from_site(site)
        expect(result[:output][:inline][:css_classes]).to eq(default_config[:output][:inline][:css_classes])
      end
    end
  end
end
