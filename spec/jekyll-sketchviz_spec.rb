require_relative '../lib/jekyll-sketchviz'

RSpec.describe JekyllSketchviz::JekyllSketchviz do
  let(:logger) do
    PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
  end

  let(:parse_context) { TestParseContext.new }

  it 'has a test' do
    expect(true).to be_true
  end
end
