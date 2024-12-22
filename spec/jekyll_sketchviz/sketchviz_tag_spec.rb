# frozen_string_literal: true

require 'jekyll'
require 'jekyll_sketchviz/liquid_tag'

RSpec.describe JekyllSketchviz::SketchvizTag do
  let(:site) do
    instance_double(
      Jekyll::Site,
      config: {}
    )
  end
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  before do
    Liquid::Template.register_tag('sketchviz', described_class)
  end

  describe '#render' do
    it 'returns a placeholder message for valid input' do
      template = Liquid::Template.parse('{% sketchviz "diagram.dot" %}')
      output = template.render(context)
      expect(output).to eq('Sketchviz: Diagram generation not yet implemented.')
    end
  end
end
