# frozen_string_literal: true

# JekyllSketchviz serves as the namespace for the Sketchviz plugin,
# encapsulating its core functionality.
module JekyllSketchviz
  # Configuration handles merging the plugin's default settings
  # with user-specified overrides from the _config.yml file.
  class Configuration
    DEFAULTS = {
      input_collection: 'graphs', # Collection name without underscore
      output: {
        inline: {
          styled: true,
          css_classes: {
            svg: 'sketchviz',
            background: 'sketchviz-bg',
            node: 'sketchviz-node',
            edge: 'sketchviz-edge'
          }
        },
        filesystem: {
          styled: false
        }
      },
      roughness: 1.5,
      bowing: 1.0,
      executable: {
        dot: 'dot'
      }
    }.freeze

    # Extracts configuration for the Sketchviz plugin from the Jekyll site object.
    # Merges default settings with those provided in _config.yml.
    #
    # @param site [Jekyll::Site] The Jekyll site object containing the configuration.
    # @return [Hash] The merged configuration hash.
    def self.from_site(site)
      Jekyll.logger.info 'Jekyll Sketchviz:', "from_site called with site: #{site.source}"
      site_config = site.config['sketchviz'] || {}
      config = deep_merge(DEFAULTS, site_config)
      Jekyll.logger.info 'Jekyll Sketchviz:', "Loaded configuration: #{config.inspect}"
      config
    end

    # Recursively merges two hashes, preferring values from the second hash.
    #
    # @param hash1 [Hash] The base hash.
    # @param hash2 [Hash] The hash to merge into the base hash.
    # @return [Hash] The resulting merged hash.
    def self.deep_merge(hash1, hash2)
      hash1.merge(hash2) do |_key, oldval, newval|
        oldval.is_a?(Hash) && newval.is_a?(Hash) ? deep_merge(oldval, newval) : newval
      end
    end
  end
end
