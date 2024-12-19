require 'jekyll_plugin_logger'

# Sample Jekyll filter.
module JekyllSketchviz
  class << self
    attr_accessor :logger
  end
  self.logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  # This Jekyll filter evaluates the input string and returns the result.
  # Use it as a calculator or one-line Ruby program evaluator.
  #
  # @param input_string [String].
  # @return [String] input string and the evaluation result.
  # @example Use like this:
  #   {{ 'TODO: show typical input' | sketchviz }} => "TODO: show output"
  def sketchviz(input_string)
    input_string.strip!
    JekyllSketchviz.logger.debug { "input_string=#{input_string}" }
    
    <<~END_OUTPUT
      <h2>TODO: generate filter output for sketchviz</h2>
      <pre>input_string = #{input_string}</pre>
    END_OUTPUT
  end

  PluginMetaLogger.instance.logger.info { 'Loaded Sketchviz plugin.' }
end

Liquid::Template.register_filter JekyllSketchviz
