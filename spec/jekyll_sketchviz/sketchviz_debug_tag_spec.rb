# frozen_string_literal: true

require 'jekyll'
require 'jekyll_sketchviz/configuration'
require 'jekyll_sketchviz/liquid_tag'

RSpec.describe JekyllSketchviz::SketchvizDebugTag do
  let(:default_config) { JekyllSketchviz::Configuration::DEFAULTS }
  let(:site) do
    instance_double(
      Jekyll::Site,
      config: site_config
    )
  end
  let(:site_config) { { 'sketchviz' => user_config } }
  let(:user_config) { nil }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  before do
    allow(JekyllSketchviz::Configuration).to receive(:from_site).with(site).and_return(default_config)
    Liquid::Template.register_tag('sketchviz_debug', described_class)
  end

  describe '#render' do
    context 'with valid parameters' do
      it 'renders the default configuration with the filename' do
        template = Liquid::Template.parse('{% sketchviz_debug "diagram.dot" %}')
        output = template.render(context)
        expect(output).to include('Sketchviz Configuration:')
        expect(output).to include(':file_name=>"diagram.dot"')
      end

      it 'merges the inline parameters into the configuration' do
        template = Liquid::Template.parse(
          '{% sketchviz_debug "diagram.dot", roughness: 2.5, bowing: 2.0, styled: true %}'
        )
        output = template.render(context)
        expect(output).to include('Sketchviz Configuration:')
        expect(output).to include(':roughness=>2.5')
        expect(output).to include(':bowing=>2.0')
        expect(output).to include(':styled=>true')
      end
    end

    context 'with invalid parameters' do
      it 'raises an error for invalid JSON structure' do
        template = Liquid::Template.parse('{% sketchviz_debug "diagram.dot", invalid: [ %}')
        expect do
          template.render!(context)
        end.to raise_error(ArgumentError, /Invalid value format: "\["/)
      end

      it 'raises an error for malformed key-value pairs' do
        template = Liquid::Template.parse('{% sketchviz_debug "diagram.dot", invalid %}')
        expect do
          template.render!(context)
        end.to raise_error(ArgumentError, /Malformed parameter: .*invalid/)
      end
    end
  end
end
