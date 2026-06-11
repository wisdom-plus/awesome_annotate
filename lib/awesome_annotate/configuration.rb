# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module AwesomeAnnotate
  class Configuration
    DEFAULT_PATH = 'config/initializers/awesome_annotate.yml'
    DEFAULT_OPTIONS = {
      env_file_path: 'config/environment.rb',
      model_dir: 'app/models',
      route_file_path: 'config/routes.rb'
    }.freeze

    TEMPLATE = <<~YAML
      # AwesomeAnnotate configuration
      #
      # Change these paths when your Rails app uses non-standard locations.
      env_file_path: config/environment.rb
      model_dir: app/models
      route_file_path: config/routes.rb
    YAML

    class << self
      def load(path = DEFAULT_PATH)
        return new unless File.exist?(path)

        loaded = YAML.safe_load_file(path, aliases: false) || {}
        raise ArgumentError, "Configuration file must contain a YAML mapping: #{path}" unless loaded.is_a?(Hash)

        new(symbolize_options(loaded))
      end

      def create(path = DEFAULT_PATH)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, TEMPLATE)
      end

      private

      def symbolize_options(options)
        options.each_with_object({}) do |(key, value), result|
          symbol_key = key.to_sym
          result[symbol_key] = value if DEFAULT_OPTIONS.key?(symbol_key)
        end
      end
    end

    attr_reader :options

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
    end
  end
end
