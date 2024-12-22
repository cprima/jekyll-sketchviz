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
          styled: false,
          path: './assets/graphs' # Default path relative to Jekyll root
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
      site_config = site.config['sketchviz'] || {}
      normalized_config = symbolize_keys(site_config)
      merged_config = deep_merge(DEFAULTS, normalized_config)
      validate_config(merged_config)
      # Jekyll.logger.info 'Jekyll Sketchviz:', "Loaded configuration: #{validated_config.inspect}"
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

    # Normalizes hash keys to symbols recursively
    #
    # @param hash [Hash] The hash with keys to be symbolized.
    # @return [Hash] The resulting hash with symbolized keys.
    def self.symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value.is_a?(Hash) ? symbolize_keys(value) : value
      end
    end

    # Validate and sanitize the configuration
    #
    # @param config [Hash] The merged configuration hash.
    # @return [Hash] The validated and sanitized configuration hash.
    def self.validate_config(config)
      validate_numerics(config)
      validate_booleans(config)
      ensure_filesystem_path(config)
      config
    end

    private_class_method def self.validate_numerics(config)
      config[:roughness] = DEFAULTS[:roughness] unless config[:roughness].is_a?(Numeric)
      config[:bowing] = DEFAULTS[:bowing] unless config[:bowing].is_a?(Numeric)
    end

    private_class_method def self.validate_booleans(config)
      validate_inline_styled(config)
      validate_filesystem_styled(config)
    end

    private_class_method def self.validate_inline_styled(config)
      config[:output][:inline][:styled] = fetch_boolean_or_default(
        config[:output][:inline],
        :styled,
        DEFAULTS[:output][:inline][:styled]
      )
    end

    private_class_method def self.validate_filesystem_styled(config)
      config[:output][:filesystem][:styled] = fetch_boolean_or_default(
        config[:output][:filesystem],
        :styled,
        DEFAULTS[:output][:filesystem][:styled]
      )
    end

    private_class_method def self.fetch_boolean_or_default(hash, key, default)
      return default unless hash.key?(key)

      hash[key] ? true : false
    end


    private_class_method def self.ensure_filesystem_path(config)
      config[:output][:filesystem][:path] ||= "./assets/#{config[:input_collection]}"
    end
  end
end
